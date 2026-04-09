import {
  beginRender,
  configureHooks,
} from './hooks';
import {
  createElement,
  type FunctionComponent,
  type VirtualChild,
  type VirtualElement,
} from './createElement';

type HostResult = { ok: true } | { ok: false; reason: string };

type EventHandler = (payload: unknown) => void;

type SerializedNode = {
  type: 'View' | 'Text' | 'Button';
  props: Record<string, unknown>;
  events: Record<string, string>;
  children: SerializedNode[];
};

type HostBridge = {
  commitTree(tree: SerializedNode): HostResult;
  log(level: string, message: string): void;
};

type BundleMeta = {
  bundleId: string;
  bundleVersion: string;
  runtimeAbiVersion: string;
  treeSchemaVersion: string;
};

let hostBridge: HostBridge | null = null;
let rootComponent: FunctionComponent | null = null;
let activeHandlers: Record<string, EventHandler> = {};
let candidateHandlers: Record<string, EventHandler> = {};
let nextHandlerIndex = 0;

function nextHandlerId(): string {
  nextHandlerIndex += 1;
  return `h_${nextHandlerIndex}`;
}

function resetCandidateHandlers(): void {
  candidateHandlers = {};
  nextHandlerIndex = 0;
}

function serializeNode(node: VirtualChild): SerializedNode {
  if (!node) {
    throw new Error('Cannot serialize empty child.');
  }

  if (typeof node.type === 'function') {
    const renderedNode = node.type({
      ...node.props,
      children: node.children,
    });
    return serializeNode(renderedNode);
  }

  const children = node.children.filter(Boolean).map((child) => serializeNode(child));

  switch (node.type) {
    case 'View':
      return {
        type: 'View',
        props: {
          padding: node.props.padding ?? 0,
          backgroundColor: node.props.backgroundColor,
        },
        events: {},
        children,
      };
    case 'Text':
      return {
        type: 'Text',
        props: {
          text: node.props.text ?? '',
          textColor: node.props.textColor,
          fontSize: node.props.fontSize,
          padding: node.props.padding,
        },
        events: {},
        children: [],
      };
    case 'Button': {
      const handler = node.props.onPress;
      const events: Record<string, string> = {};

      if (typeof handler === 'function') {
        const handlerId = nextHandlerId();
        candidateHandlers[handlerId] = handler as EventHandler;
        events.onPress = handlerId;
      }

      return {
        type: 'Button',
        props: {
          label: node.props.label ?? '',
          padding: node.props.padding,
        },
        events,
        children: [],
      };
    }
    default:
      throw new Error(`Unsupported intrinsic node type: ${String(node.type)}`);
  }
}

function renderRoot(): void {
  if (!hostBridge || !rootComponent) {
    throw new Error('Bundle runtime is not bootstrapped.');
  }

  beginRender();
  resetCandidateHandlers();

  const tree = serializeNode(createElement(rootComponent, null));
  const result = hostBridge.commitTree(tree);

  if (result.ok) {
    activeHandlers = candidateHandlers;
    return;
  }

  hostBridge.log('error', `commit rejected: ${result.reason}`);
}

export function registerBundle(meta: BundleMeta, app: FunctionComponent): void {
  rootComponent = app;
  configureHooks(() => {
    renderRoot();
  });

  globalThis.__poc_bundle_meta = meta;
  globalThis.__poc_bootstrap = (nextHostBridge: HostBridge): void => {
    hostBridge = nextHostBridge;
    renderRoot();
  };

  globalThis.__poc_dispatch_event = (
    handlerId: string,
    payload: unknown,
  ): void => {
    const handler = activeHandlers[handlerId];
    if (!handler) {
      throw new Error(`Unknown handler id: ${handlerId}`);
    }

    handler(payload);
  };
}

export { createElement };

import {
  beginRender,
  commitHookState,
  configureHooks,
  rollbackHookState,
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
  commitPatch(patch: TreePatch): HostResult;
  log(level: string, message: string): void;
};

type BundleMeta = {
  bundleId: string;
  bundleVersion: string;
  runtimeAbiVersion: string;
  treeSchemaVersion: string;
};

type TreePatchOperation = {
  op: 'replace' | 'insert' | 'remove';
  path: number[];
  node?: SerializedNode;
};

type TreePatch = {
  ops: TreePatchOperation[];
};

let hostBridge: HostBridge | null = null;
let rootComponent: FunctionComponent | null = null;
let activeTree: SerializedNode | null = null;
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

function areRecordsEqual(
  left: Record<string, unknown>,
  right: Record<string, unknown>,
): boolean {
  return JSON.stringify(left) === JSON.stringify(right);
}

function derivePatch(
  previousNode: SerializedNode,
  nextNode: SerializedNode,
  path: number[] = [],
): TreePatchOperation[] {
  if (
    previousNode.type !== nextNode.type ||
    !areRecordsEqual(previousNode.props, nextNode.props) ||
    !areRecordsEqual(previousNode.events, nextNode.events)
  ) {
    return [{ op: 'replace', path, node: nextNode }];
  }

  const childOperations: TreePatchOperation[] = [];

  const previousChildren = previousNode.children;
  const nextChildren = nextNode.children;

  const sharedLength = Math.min(previousChildren.length, nextChildren.length);

  for (let index = 0; index < sharedLength; index += 1) {
    const operations = derivePatch(
      previousChildren[index],
      nextChildren[index],
      [...path, index],
    );
    childOperations.push(...operations);
  }

  if (previousChildren.length + 1 === nextChildren.length) {
    childOperations.push({
      op: 'insert',
      path: [...path, nextChildren.length - 1],
      node: nextChildren[nextChildren.length - 1],
    });
    return childOperations;
  }

  if (previousChildren.length === nextChildren.length + 1) {
    childOperations.push({
      op: 'remove',
      path: [...path, previousChildren.length - 1],
    });
    return childOperations;
  }

  if (childOperations.length <= 1) {
    return childOperations;
  }

  return [{ op: 'replace', path, node: nextNode }];
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
  let result: HostResult;

  if (activeTree == null) {
    result = hostBridge.commitTree(tree);
  } else {
    const operations = derivePatch(activeTree, tree);

    if (operations.length === 0) {
      activeTree = tree;
      activeHandlers = candidateHandlers;
      commitHookState();
      return;
    }

    result = hostBridge.commitPatch({ ops: operations });
  }

  if (result.ok) {
    activeTree = tree;
    activeHandlers = candidateHandlers;
    commitHookState();
    return;
  }

  rollbackHookState();
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
    activeTree = null;
    activeHandlers = {};
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

export { Button, createElement, Text, View } from './createElement';

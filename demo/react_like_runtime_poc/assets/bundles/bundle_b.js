"use strict";
(() => {
  // src/runtime/hooks.ts
  var hookStates = [];
  var hookIndex = 0;
  var scheduleRender = () => {
  };
  function configureHooks(onScheduleRender) {
    scheduleRender = onScheduleRender;
  }
  function beginRender() {
    hookIndex = 0;
  }
  function useState(initialValue) {
    const currentIndex = hookIndex;
    hookIndex += 1;
    if (hookStates[currentIndex] === void 0) {
      hookStates[currentIndex] = initialValue;
    }
    const setState = (nextValue) => {
      const currentValue = hookStates[currentIndex];
      hookStates[currentIndex] = typeof nextValue === "function" ? nextValue(currentValue) : nextValue;
      scheduleRender();
    };
    return [hookStates[currentIndex], setState];
  }

  // src/runtime/createElement.ts
  function createElement(type, props, ...children) {
    return {
      type,
      props: props ?? {},
      children: children.flat().filter(Boolean)
    };
  }

  // src/runtime/renderer.ts
  var hostBridge = null;
  var rootComponent = null;
  var activeHandlers = {};
  var candidateHandlers = {};
  var nextHandlerIndex = 0;
  function nextHandlerId() {
    nextHandlerIndex += 1;
    return `h_${nextHandlerIndex}`;
  }
  function resetCandidateHandlers() {
    candidateHandlers = {};
    nextHandlerIndex = 0;
  }
  function serializeNode(node) {
    if (!node) {
      throw new Error("Cannot serialize empty child.");
    }
    if (typeof node.type === "function") {
      const renderedNode = node.type({
        ...node.props,
        children: node.children
      });
      return serializeNode(renderedNode);
    }
    const children = node.children.filter(Boolean).map((child) => serializeNode(child));
    switch (node.type) {
      case "View":
        return {
          type: "View",
          props: {
            padding: node.props.padding ?? 0,
            backgroundColor: node.props.backgroundColor
          },
          events: {},
          children
        };
      case "Text":
        return {
          type: "Text",
          props: {
            text: node.props.text ?? "",
            textColor: node.props.textColor,
            fontSize: node.props.fontSize,
            padding: node.props.padding
          },
          events: {},
          children: []
        };
      case "Button": {
        const handler = node.props.onPress;
        const events = {};
        if (typeof handler === "function") {
          const handlerId = nextHandlerId();
          candidateHandlers[handlerId] = handler;
          events.onPress = handlerId;
        }
        return {
          type: "Button",
          props: {
            label: node.props.label ?? "",
            padding: node.props.padding
          },
          events,
          children: []
        };
      }
      default:
        throw new Error(`Unsupported intrinsic node type: ${String(node.type)}`);
    }
  }
  function renderRoot() {
    if (!hostBridge || !rootComponent) {
      throw new Error("Bundle runtime is not bootstrapped.");
    }
    beginRender();
    resetCandidateHandlers();
    const tree = serializeNode(createElement(rootComponent, null));
    const result = hostBridge.commitTree(tree);
    if (result.ok) {
      activeHandlers = candidateHandlers;
      return;
    }
    hostBridge.log("error", `commit rejected: ${result.reason}`);
  }
  function registerBundle(meta, app) {
    rootComponent = app;
    configureHooks(() => {
      renderRoot();
    });
    globalThis.__poc_bundle_meta = meta;
    globalThis.__poc_bootstrap = (nextHostBridge) => {
      hostBridge = nextHostBridge;
      renderRoot();
    };
    globalThis.__poc_dispatch_event = (handlerId, payload) => {
      const handler = activeHandlers[handlerId];
      if (!handler) {
        throw new Error(`Unknown handler id: ${handlerId}`);
      }
      handler(payload);
    };
  }

  // src/apps/bundleB.tsx
  function App() {
    const [count, setCount] = useState(10);
    return /* @__PURE__ */ createElement(View, { padding: 24, backgroundColor: "#FFF7E8" }, /* @__PURE__ */ createElement(Text, { text: "Counter Demo B", fontSize: 22, textColor: "#111111" }), /* @__PURE__ */ createElement(Text, { text: `Counter: ${count}`, fontSize: 16, textColor: "#444444" }), /* @__PURE__ */ createElement(
      Button,
      {
        label: "Boost",
        padding: 12,
        onPress: () => {
          setCount((current) => current + 2);
        }
      }
    ));
  }
  registerBundle(
    {
      bundleId: "bundle-b",
      bundleVersion: "2.0.0",
      runtimeAbiVersion: "poc-v1",
      treeSchemaVersion: "poc-tree-v1"
    },
    App
  );
})();

"use strict";
(() => {
  // src/runtime/hooks.ts
  var hookStates = [];
  var committedHookStates = [];
  var hookIndex = 0;
  var scheduleRender = () => {
  };
  function configureHooks(onScheduleRender) {
    scheduleRender = onScheduleRender;
  }
  function beginRender() {
    hookIndex = 0;
  }
  function commitHookState() {
    committedHookStates = [...hookStates];
  }
  function rollbackHookState() {
    hookStates = [...committedHookStates];
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
  var View = "View";
  var Text = "Text";
  var Button = "Button";
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
  var activeTree = null;
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
  function areRecordsEqual(left, right) {
    return JSON.stringify(left) === JSON.stringify(right);
  }
  function derivePatch(previousNode, nextNode, path = []) {
    if (previousNode.type !== nextNode.type || previousNode.key !== nextNode.key || !areRecordsEqual(previousNode.props, nextNode.props) || !areRecordsEqual(previousNode.events, nextNode.events)) {
      return [{ op: "replace", path, node: nextNode }];
    }
    const childOperations = [];
    const previousChildren = previousNode.children;
    const nextChildren = nextNode.children;
    const keyedMovePatch = deriveKeyedMovePatch(previousChildren, nextChildren, path);
    const comparablePreviousChildren = keyedMovePatch?.reorderedChildren ?? previousChildren;
    if (keyedMovePatch) {
      childOperations.push(...keyedMovePatch.operations);
    }
    const sharedLength = Math.min(
      comparablePreviousChildren.length,
      nextChildren.length
    );
    for (let index = 0; index < sharedLength; index += 1) {
      const operations = derivePatch(
        comparablePreviousChildren[index],
        nextChildren[index],
        [...path, index]
      );
      childOperations.push(...operations);
    }
    if (keyedMovePatch) {
      return childOperations;
    }
    if (previousChildren.length + 1 === nextChildren.length) {
      childOperations.push({
        op: "insert",
        path: [...path, nextChildren.length - 1],
        node: nextChildren[nextChildren.length - 1]
      });
      return childOperations;
    }
    if (previousChildren.length === nextChildren.length + 1) {
      childOperations.push({
        op: "remove",
        path: [...path, previousChildren.length - 1]
      });
      return childOperations;
    }
    return childOperations;
  }
  function deriveKeyedMovePatch(previousChildren, nextChildren, path) {
    if (previousChildren.length <= 1 || previousChildren.length !== nextChildren.length) {
      return null;
    }
    const previousKeys = previousChildren.map((child) => child.key);
    const nextKeys = nextChildren.map((child) => child.key);
    if (previousKeys.some((key) => typeof key !== "string") || nextKeys.some((key) => typeof key !== "string")) {
      return null;
    }
    const previousKeyList = previousKeys;
    const nextKeyList = nextKeys;
    if (new Set(previousKeyList).size !== previousKeyList.length || new Set(nextKeyList).size !== nextKeyList.length) {
      return null;
    }
    const sameMembers = previousKeyList.length === nextKeyList.length && previousKeyList.every((key) => nextKeyList.includes(key));
    if (!sameMembers) {
      return null;
    }
    const sameOrder = previousKeyList.every((key, index) => key === nextKeyList[index]);
    if (sameOrder) {
      return null;
    }
    const workingKeys = [...previousKeyList];
    const reorderedChildren = [...previousChildren];
    const operations = [];
    for (let targetIndex = 0; targetIndex < nextKeyList.length; targetIndex += 1) {
      const targetKey = nextKeyList[targetIndex];
      const currentIndex = workingKeys.indexOf(targetKey);
      if (currentIndex === -1) {
        return null;
      }
      if (currentIndex === targetIndex) {
        continue;
      }
      operations.push({
        op: "move",
        from: [...path, currentIndex],
        path: [...path, targetIndex]
      });
      const [movedKey] = workingKeys.splice(currentIndex, 1);
      workingKeys.splice(targetIndex, 0, movedKey);
      const [movedChild] = reorderedChildren.splice(currentIndex, 1);
      reorderedChildren.splice(targetIndex, 0, movedChild);
    }
    return {
      operations,
      reorderedChildren
    };
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
    const key = typeof node.props.key === "string" ? node.props.key : void 0;
    switch (node.type) {
      case "View":
        return {
          type: "View",
          key,
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
          key,
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
          key,
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
    let result;
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
      activeTree = null;
      activeHandlers = {};
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

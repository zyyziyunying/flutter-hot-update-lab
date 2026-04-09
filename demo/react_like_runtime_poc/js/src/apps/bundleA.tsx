import { useState } from '../runtime/hooks';
import { createElement, registerBundle } from '../runtime/renderer';

function App() {
  const [count, setCount] = useState(0);

  return (
    <View padding={24} backgroundColor="#EAF4FF">
      <Text text="Counter Demo A" fontSize={22} textColor="#111111" />
      <Text text={`Counter: ${count}`} fontSize={16} textColor="#444444" />
      <Button
        label="Add"
        padding={12}
        onPress={() => {
          setCount((current) => current + 1);
        }}
      />
    </View>
  );
}

registerBundle(
  {
    bundleId: 'bundle-a',
    bundleVersion: '1.0.0',
    runtimeAbiVersion: 'poc-v1',
    treeSchemaVersion: 'poc-tree-v1',
  },
  App,
);

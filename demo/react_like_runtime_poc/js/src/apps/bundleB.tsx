import { useState } from '../runtime/hooks';
import {
  Button,
  createElement,
  registerBundle,
  Text,
  View,
} from '../runtime/renderer';

function App() {
  const [count, setCount] = useState(10);

  return (
    <View padding={24} backgroundColor="#FFF7E8">
      <Text text="Counter Demo B" fontSize={22} textColor="#111111" />
      <Text text={`Counter: ${count}`} fontSize={16} textColor="#444444" />
      <Button
        label="Boost"
        padding={12}
        onPress={() => {
          setCount((current) => current + 2);
        }}
      />
    </View>
  );
}

registerBundle(
  {
    bundleId: 'bundle-b',
    bundleVersion: '2.0.0',
    runtimeAbiVersion: 'poc-v1',
    treeSchemaVersion: 'poc-tree-v1',
  },
  App,
);

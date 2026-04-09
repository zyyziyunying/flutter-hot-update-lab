import { useState } from '../runtime/hooks';
import {
  Button,
  createElement,
  registerBundle,
  Text,
  View,
} from '../runtime/renderer';

function App() {
  const [items, setItems] = useState(['Milk', 'Coffee']);

  const nextItemLabel = `Item ${items.length + 1}`;

  return (
    <View padding={24} backgroundColor="#EAF4FF">
      <Text text="List Demo A" fontSize={22} textColor="#111111" />
      <Text
        text="Single-page insert/remove patch demo"
        fontSize={16}
        textColor="#444444"
      />
      <View padding={12} backgroundColor="#FFFFFF">
        {items.map((item) => (
          <Text key={item} text={item} fontSize={16} textColor="#222222" />
        ))}
      </View>
      <Button
        label="Add item"
        padding={12}
        onPress={() => {
          setItems((current) => [...current, nextItemLabel]);
        }}
      />
      <Button
        label="Remove last"
        padding={12}
        onPress={() => {
          setItems((current) =>
            current.length <= 1 ? current : current.slice(0, current.length - 1),
          );
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

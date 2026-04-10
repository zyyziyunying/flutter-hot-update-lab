import { useState } from '../runtime/hooks';
import {
  Button,
  createElement,
  registerBundle,
  Text,
  View,
} from '../runtime/renderer';

function App() {
  const [items, setItems] = useState(['A', 'B']);
  const [selected, setSelected] = useState('none');

  return (
    <View padding={24} backgroundColor="#F5F0FF">
      <Text text="Keyed Button Demo C" fontSize={22} textColor="#111111" />
      <Text text={`Selected: ${selected}`} fontSize={16} textColor="#444444" />
      <View padding={12} backgroundColor="#FFFFFF">
        {items.map((item, index) => (
          <Button
            key={item}
            label={`Pick ${item}`}
            padding={12 + index}
            onPress={() => {
              setSelected(item);
            }}
          />
        ))}
      </View>
      <Button
        label="Reverse order"
        padding={12}
        onPress={() => {
          setItems((current) => [...current].reverse());
        }}
      />
    </View>
  );
}

registerBundle(
  {
    bundleId: 'bundle-c',
    bundleVersion: '1.0.0',
    runtimeAbiVersion: 'poc-v1',
    treeSchemaVersion: 'poc-tree-v1',
  },
  App,
);

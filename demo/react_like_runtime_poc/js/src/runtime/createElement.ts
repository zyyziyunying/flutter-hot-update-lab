export type ElementType = string | FunctionComponent;

export type FunctionComponent = (
  props: Record<string, unknown> & { children?: VirtualChild[] },
) => VirtualChild;

export type VirtualChild = VirtualElement | null | undefined | false;

export interface VirtualElement {
  type: ElementType;
  props: Record<string, unknown>;
  children: VirtualChild[];
}

export function createElement(
  type: ElementType,
  props?: Record<string, unknown> | null,
  ...children: VirtualChild[]
): VirtualElement {
  return {
    type,
    props: props ?? {},
    children: children.flat().filter(Boolean) as VirtualChild[],
  };
}

declare global {
  namespace JSX {
    interface IntrinsicElements {
      View: Record<string, unknown>;
      Text: Record<string, unknown>;
      Button: Record<string, unknown>;
    }
  }
}

let hookStates: unknown[] = [];
let committedHookStates: unknown[] = [];
let hookIndex = 0;
let scheduleRender: () => void = () => {};

export function configureHooks(onScheduleRender: () => void): void {
  scheduleRender = onScheduleRender;
}

export function beginRender(): void {
  hookIndex = 0;
}

export function commitHookState(): void {
  committedHookStates = [...hookStates];
}

export function rollbackHookState(): void {
  hookStates = [...committedHookStates];
}

export function useState<T>(
  initialValue: T,
): [T, (nextValue: T | ((currentValue: T) => T)) => void] {
  const currentIndex = hookIndex;
  hookIndex += 1;

  if (hookStates[currentIndex] === undefined) {
    hookStates[currentIndex] = initialValue;
  }

  const setState = (nextValue: T | ((currentValue: T) => T)): void => {
    const currentValue = hookStates[currentIndex] as T;
    hookStates[currentIndex] =
      typeof nextValue === 'function'
        ? (nextValue as (currentValue: T) => T)(currentValue)
        : nextValue;

    scheduleRender();
  };

  return [hookStates[currentIndex] as T, setState];
}

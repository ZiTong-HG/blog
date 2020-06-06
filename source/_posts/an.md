---
title: React Hooks实践应用
date: 2020-06-06 14:43:41
categories: React
tags:
  - React
  - React Hooks
---

React16.8 发布已经很长世间, 这段时间项目不忙, 正好准备使用 React Hooks 进行重构升级。React Hooks 的特性是它可以让你在不编写 class 的情况下使用 state 以及其他的 React 的特性,下面来让我们一起进入 React Hooks<!--more-->的新特性实践吧！

### ** React Hook 特性 **

1. 完全可选的。 你无需重写任何已有代码就可以在一些组件中尝试 Hook。但是如果你不想，你不必现在就去学习或使用 Hook。
2. 100% 向后兼容的。 Hook 不包含任何破坏性改动。
3. 现在可用。 Hook 已发布于 v16.8.0

### ** 官方 10 种 React Hooks **

#### ** 1.useState **

useState 可以让我们在不编写 class 的情况下使用 state,以此可以达到让函数组建重新渲染

initialState 参数只会在组件的初始渲染中起作用，后续渲染时会被忽略。如果初始 state 需要通过复杂计算获得，则可以传入一个函数，在函数中计算并返回初始的 state，此函数只在初始渲染时被调用：

```tsx
function useState<S = undefined>(): [
  S | undefined,
  Dispatch<SetStateAction<S | undefined>>
]

const [state, setState] = useState(() => {
  const initialState = someExpensiveComputation(props)
  return initialState
})
```

```tsx
const App = () => {
  const [count, setCount] = useState(0) // number 类型
  const [obj, setObject] = React.useState({
    count: 0,
    name: "alex",
  }) // object 类型
  const [todos, setTodos] = useState([{ text: "Learn Hooks" }]) // 数组类型

  return (
    <div>
      <p>current value {obj.count}</p>
      <button onClick={() => setCount({ ...obj, count: count + 1 })}>+</button>
      <button onClick={() => setCount({ ...obj, count: count + 1 })}>-</button>
    </div>
  )
}
```

setState 可以局部的更新,但是 useState 必须把真个对象修改后的只丢进去来进行更新,useState 覆盖式更新 setState 调合 Object.assign()

#### ** 2、9.useEffect、 useLayoutEffect ** ####
**useEffect**:

该 Hook 接收一个包含命令式、且可能有副作用代码的函数。

React 会等待浏览器完成画面渲染之后才会延迟调用 useEffect，因此会使得处理额外操作很方便。

在函数组件主体内（这里指在 React 渲染阶段）改变 DOM、添加订阅、设置定时器、记录日志以及执行其他包含副作用的操作都是不被允许的，因为这可能会产生莫名其妙的 bug 并破坏 UI 的一致性。

使用 useEffect 完成副作用操作。赋值给 useEffect 的函数会在组件渲染到屏幕之后执行。你可以把 effect 看作从 React 的纯函数式世界通往命令式世界的逃生通道。

**useLayoutEffect**:
其函数签名与 useEffect 相同，但它会在所有的 DOM 变更之后同步调用 effect。可以使用它来读取 DOM 布局并同步触发重渲染。在浏览器执行绘制之前，useLayoutEffect 内部的更新计划将被同步刷新。

useLayoutEffect 与 componentDidMount、componentDidUpdate 的调用阶段是一样的。但是，我们推荐你一开始先用 useEffect，只有当它出问题的时候再尝试使用 useLayoutEffect.

```tsx
function useEffect(effect: EffectCallback, deps?: DependencyList): void
```

```tsx
let timer = null
const App = () => {
  const [count, setCount] = React.useState(0)

  React.useEffect(() => {
    document.title = "componentDidMount" + count
  }, [count])

  React.useEffect(() => {
    timer = setInterval(() => {
      setCount((prevCount) => prevCount + 1)
    }, 1000)
    // 一定注意下这个顺序：
    // 告诉react在下次重新渲染组件之后，同时是下次执行上面setInterval之前调用
    return () => {
      document.title = "componentWillUnmount"
      clearInterval(timer)
    }
  }, [])

  return (
    <div>
      Count: {count}
      <button onClick={() => clearInterval(timer)}>clear</button>
    </div>
  )
}
```

1. 比如第一个 useEffect 中,理解起来就是一旦 count 值发生改变，则修改 documen.title 值.
2. 而第二个 useEffect 中传递了一个空数组[],这种情况下只有在组件初始化或销毁的时候才会触发,用来代替 componentDidMount 和 componentWillUnmount 慎用.
3. 还有另外一个情况,就是不传递第二个参数,也就是 useEffect 只接收了第一个函数参数,代表不监听任何参数变化.每次渲染 DOM 之后,都会执行 useEffect 中的函数,类似替代 componentDidUpdate.

#### ** 3.useContext **

接收一个 context 对象（React.createContext 的返回值）并返回该 context 的当前值。当前的 context 值由上层组件中距离当前组件最近的 <MyContext.Provider> 的 value prop 决定。

当组件上层最近的 <MyContext.Provider> 更新时，该 Hook 会触发重渲染，并使用最新传递给 MyContext provider 的 context value 值。即使祖先使用 React.memo 或 shouldComponentUpdate，也会在组件本身使用 useContext 时重新渲染。

如果你在接触 Hook 前已经对 context API 比较熟悉，那应该可以理解，useContext(MyContext) 相当于 class 组件中的 static contextType = MyContext 或者 <MyContext.Consumer>。

useContext(MyContext) 只是让你能够读取 context 的值以及订阅 context 的变化。你仍然需要在上层组件树中使用 <MyContext.Provider> 来为下层组件提供 context。

```tsx
function useContext<T>(
  context: Context<T> /*, (not public API) observedBits?: number|boolean */
): T
```

```tsx
const colorContext = React.createContext("gray")

const Bar = () => {
  // useContext 的参数必须是 context 对象本身
  const color = React.useContext(colorContext)
  return <div>{color}</div>
}

const Foo = () => <Bar />

const App = () => {
  return (
    <colorContext.Provider value={"red"}>
      <Foo />
    </colorContext.Provider>
  )
}
```

useContext 可以解决 Consumer 多状态嵌套的问题

#### **4.useReducer 　**

useState 的替代方案。它接收一个形如 (state, action) => newState 的 reducer，并返回当前的 state 以及与其配套的 dispatch 方法。（如果你熟悉 Redux 的话，就已经知道它如何工作了。）

在某些场景下，useReducer 会比 useState 更适用，例如 state 逻辑较复杂且包含多个子值，或者下一个 state 依赖于之前的 state 等。并且，使用 useReducer 还能给那些会触发深更新的组件做性能优化，因为你可以向子组件传递 dispatch 而不是回调函数 。

```tsx
function useReducer<R extends Reducer<any, any>>(
  reducer: R,
  initialState: ReducerState<R>,
  initializer?: undefined
): [ReducerState<R>, Dispatch<ReducerAction<R>>]
```

```tsx
interface IState{
  count: number
}

interface IAction{
  type: 'increment' |　'decrement'
}

const initialState: IState = { count: 0 }

const init = (initialCount) => {
  return { count: 0 }
}

function reducer(state: IState, action: IAction){
  switch(action.type){
    case 'increment':
      return { count: state.count + 1 }
    case 'decrement':
      return { count:state.count - 1 }
    default:
      throw new Error()
  }
}

const App = () => {
  const [state, dispatch] = React.useReducer(reducer, initialState)

  // 惰性传值
  const [state, dispatch] = React.useReducer(reducer, initialCount, init)
  return (
    <>
      <p>{state.count}</p>
      <button onClick={() => dispatch('decrement')}>-</button>
      <button onClick={() => dispatch('increment')}>+</button>
    <>
  )
}
```
useReducer可以直接传值,也可以惰性传值,惰性传值可以达到重置,直接访问外部Reducer
如果 Reducer Hook 的返回值与当前 state 相同，React 将跳过子组件的渲染及副作用的执行


#### ** 5、6 useCallback、useMemo ** ####
都是返回一个 memoized 回调函数。
当传入的依赖项改变时,函数才会执行更新,当你把回调函数传递给经过优化的并使用引用相等性去避免非必要渲染（例如 shouldComponentUpdate）的子组件时，它将非常有用

```tsx
function useCallback<T extends (...args: any[]) => any>(callback: T, deps: DependencyList): T;

function useMemo<T>(factory: () => T, deps: DependencyList | undefined): T;

useCallbacl(fn, deps) === useMemo(() => fn, deps)
```

```tsx
const memoizedCallback = useCallback(
  () => {
    doSomething(a, b);
  },
  [a, b]
);

const memoizedValue = useMemo(() => computeExpensiveValue(a, b), [a, b]);
```

#### ** 7 useRef ** ####

useRef 返回一个可变的 ref 对象，其 .current 属性被初始化为传入的参数（initialValue）。返回的 ref 对象在组件的整个生命周期内保持不变。

ref这是一个普通 Javascript 对象。而 useRef() 和自建一个 {current: ...} 对象的唯一区别是，useRef 会在每次渲染时返回同一个 ref 对象。

当 ref 对象内容发生变化时，useRef 并不会通知你。变更 .current 属性不会引发组件重新渲染。如果想要在 React 绑定或解绑 DOM 节点的 ref 时运行某些代码，则需要使用回调 ref 来实现。

useRef 就像是可以在其 .current 属性中保存一个可变值的"盒子"

```tsx
function useRef<T>(initialValue: T): MutableRefObject<T>;
```

```tsx
function TextInputWithFocusButton() {
  const inputEl = useRef(null);
  const onButtonClick = () => {
    // `current` 指向已挂载到 DOM 上的文本输入元素
    inputEl.current.focus();
  }
  return (
    <>
      <input ref={inputEl} type="text" />
      <button onClick={onButtonClick}>Focus the input</button>
    </>
  )
}
```

#### ** 8 useImperativeHandle ** ####

useImperativeHandle 可以让你在使用 ref 时自定义暴露给父组件的实例值。在大多数情况下，应当避免使用 ref 这样的命令式代码。useImperativeHandle 应当与 forwardRef 一起使用

```tsx
function useImperativeHandle<T, R extends T>(ref: Ref<T>|undefined, init: () => R, deps?: DependencyList): void;
```

```tsx
function FancyInput(props, ref) {
  const inputRef = useRef();
  useImperativeHandle(ref, () => ({
    focus: () => {
      inputRef.current.focus();
    }
  }));
  return <input ref={inputRef} ... />;
}
FancyInput = forwardRef(FancyInput);
```
渲染 <FancyInput ref={inputRef} /> 的父组件可以调用 inputRef.current.focus()

#### ** 10.useDebugValue ** ####

useDebugValue 可用于在 React 开发者工具中显示自定义 hook 的标签。
```tsx
function useDebugValue<T>(value: T, format?: (value: T) => any): void;
```
这个我用的比较少,就暂不赘叙、有兴趣可以查看官网的demo
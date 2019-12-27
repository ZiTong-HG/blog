---
title: 理解React中的Redux
date: 2019-02-02 19:13:54
categories: React
tags:
  - react
  - javascript
---
Redux 是 JavaScript 状态容器，提供可预测化的状态管理,可以让你构建一致化的应用，运行于不同的环境(客户端、服务器、原生应用)，并且易于测试。不仅于此，它还提供 超爽的开发体验，比如有一个时间旅行调试器可以编辑后实时预览。<!--more-->Redux 除了和 React 一起用外，还支持其它界面库。 它体小精悍(只有2kB，包括依赖)

### ** 学习redux之前,首先得弄清楚一些概念 ** ###

1.redux在react开发中所起到的作用——状态集中管理
2.弄清楚redux中如何实现状态管理——store、action、reducer三个概念
3.解读redux中源码的实现(createStore, combineReducers, bindActionCreators, applyMiddleware, compose, ActionTypes)

![ak](/images/redux.png)
### ** 三大原则 ** ###
** 单一数据源 **

整个应用的state被存储在一棵object tree中，并且这个object tree只存在于唯一一个store中。

** State是只读的 **

惟一改变 state 的方法就是触发 action，action 是一个用于描述已发生事件的普通对象。

** 使用纯函数来执行修改 **

为了描述action如何改变状态树，我们需要编写reducers。Reducer只是一些纯函数，他接受先前的state和action，并返回新的state对象。

### ** Action ** ###

首先，让我们来给 action 下个定义。

Action 是把数据从应用（译者注：这里之所以不叫 view 是因为这些数据有可能是服务器响应，用户输入或其它非 view 的数据 ）传到 store 的有效载荷。它是 store 数据的唯一来源。一般来说你会通过 store.dispatch() 将 action 传到 store。
添加新 todo 任务的 action 是这样的：

``` js
  ActionTypes.js

  const ADD_TODO = 'ADD_TODO'
```

``` js
  Action.js

  {
    type: ADD_TODO,
    text: 'Build my first Redux app'
  }
```
Action 本质上是 JavaScript 普通对象。我们约定，action 内必须使用一个字符串类型的 type 字段来表示将要执行的动作。多数情况下，type 会被定义成字符串常量。当应用规模越来越大时，建议使用单独的模块或文件来存放 action。
``` js
import { ADD_TODO } from '../actionTypes'
```
>** 样板文件使用提醒 **
使用单独的模块或文件来定义 action type 常量并不是必须的，甚至根本不需要定义。对于小应用来说，使用字符串做 action type 更方便些。不过，在大型应用中把它们显式地定义成常量还是利大于弊的。参照 减少样板代码 获取更多保持代码简洁的实践经验。

** Action 创建函数 **

Action 创建函数 就是生成 action 的方法。“action” 和 “action 创建函数” 这两个概念很容易混在一起，使用时最好注意区分。

在 Redux 中的 action 创建函数只是简单的返回一个 action:

``` js
  Action.js

  function addTodo(text) {
    return {
      type: ADD_TODO,
      text
    }
  }
```
这样做将使 action 创建函数更容易被移植和测试。

Redux 中只需把 action 创建函数的结果传给 dispatch() 方法即可发起一次 dispatch 过程。

``` js
  dispatch(addTodo(text))
```

或者创建一个 被绑定的 action 创建函数 来自动 dispatch：

``` js
  const boundAddTodo = text => dispatch(addTodo(text))
```

然后直接调用它们：


``` js
  boundAddTodo(text);
```
store 里能直接通过 store.dispatch() 调用 dispatch() 方法，但是多数情况下你会使用 react-redux 提供的 connect() 帮助器来调用。bindActionCreators() 可以自动把多个 action 创建函数 绑定到 dispatch() 方法上。

### ** Reducer ** ###

Reducers 指定了应用状态的变化如何响应 actions 并发送到 store 的，记住actions只是描述了有事情发生了这一事实，并没有描述应用如何更新。 Reducers 就是一个纯函数，接收旧的 state 和 action，返回新的 state。

** Action 处理 **
``` js
  (previousState, action) => newState
```

** Reducers 处理 **
``` js
  function todoApp(state = initialState, action) {
    switch (action.type) {
      case SET_VISIBILITY_FILTER:
        return Object.assign({}, state, {
          visibilityFilter: action.filter
        })
      default:
        return state
    }
  }
```
>** 注意 **:                                                                                                              
1.** 不要修改  **state。 使用 Object.assign() 新建了一个副本。不能这样使用 Object.assign(state, { visibilityFilter: action.filter })，因为它会改变第一个参数的值。你必须把第一个参数设置为空对象。你也可以开启对ES7提案对象展开运算符的支持, 从而使用 { ...state, ...newState } 达到相同的目的。                                                                        
2.** 在 default 情况下返回旧的 ** state。遇到未知的 action 时，一定要返回旧的 state。

 reducer可以拆分成多个来管理全局中的state，每个 reducer 的 state 参数都不同，分别对应它管理的那部分 state 数据。也可以放到不同的文件中，以保持其独立性并专门处理不同的数据域。

 最后，Redux 提供了 combineReducers() 工具类来做上面 todoApp 做的事情，这样就能消灭一些样板代码了。有了它，可以这样重构 todoApp：
 ``` js
  export default function todoApp(state = {}, action) {
    return {
      visibilityFilter: visibilityFilter(state.visibilityFilter, action),
      todos: todos(state.todos, action)
    }
  }
```

### ** Store ** ###

我们学会了使用 action 来描述“发生了什么”，和使用 reducers 来根据 action 更新 state 的用法。

Store 就是把它们联系到一起的对象。Store 有以下职责：

+ 维持应用的 state；
+ 提供 getState() 方法获取 state；
+ 提供 dispatch(action) 方法更新 state；
+ 通过 subscribe(listener) 注册监听器;
+ 通过 subscribe(listener) 返回的函数注销监听器。
+ 再次强调一下 Redux 应用只有一个单一的 store。当需要拆分数据处理逻辑时，你应该使用 reducer 组合 而不是创建多个 store。

根据已有的 reducer 来创建 store 是非常容易的，我们使用 combineReducers() 将多个 reducer 合并成为一个。现在我们将其导入，并传递 createStore()。
 ``` js
  import { createStore } from 'redux'
  import todoApp from './reducers'
  let store = createStore(todoApp)
```
createStore() 的第二个参数是可选的, 用于设置 state 初始状态。这对开发同构应用时非常有用，服务器端 redux 应用的 state 结构可以与客户端保持一致, 那么客户端可以将从网络接收到的服务端 state 直接用于本地数据初始化。

 ``` js
let store = createStore(todoApp, window.STATE_FROM_SERVER)
```

### ** 数据流 ** ###

严格的单向数据流是 Redux 架构的设计核心。

这意味着应用中所有的数据都遵循相同的生命周期，这样可以让应用变得更加可预测且容易理解。同时也鼓励做数据范式化，这样可以避免使用多个且独立的无法相互引用的重复数据。

** Redux 应用中数据的生命周期遵循下面 4 个步骤： **

#### 1.调用 store.dispatch(action) ####

Action 就是一个描述“发生了什么”的普通对象。比如：
``` js
  { type: 'LIKE_ARTICLE', articleId: 42 }
  { type: 'FETCH_USER_SUCCESS', response: { id: 3, name: 'Mary' } }
  { type: 'ADD_TODO', text: 'Read the Redux docs.' }
```
可以把 action 理解成新闻的摘要。如 “玛丽喜欢42号文章。” 或者 “任务列表里添加了'学习 Redux 文档'”。

你可以在任何地方调用 store.dispatch(action)，包括组件中、XHR 回调中、甚至定时器中。

#### 2.Redux store 调用传入的 reducer 函数 ####

Store 会把两个参数传入 reducer： 当前的 state 树和 action。例如，在这个 todo 应用中，根 reducer 可能接收这样的数据：
``` js
 // 当前应用的 state（todos 列表和选中的过滤器）
 let previousState = {
   visibleTodoFilter: 'SHOW_ALL',
   todos: [
     {
       text: 'Read the docs.',
       complete: false
     }
   ]
 }

 // 将要执行的 action（添加一个 todo）
 let action = {
   type: 'ADD_TODO',
   text: 'Understand the flow.'
 }

 // reducer 返回处理后的应用状态
 let nextState = todoApp(previousState, action)
```
注意 reducer 是纯函数。它仅仅用于计算下一个 state。它应该是完全可预测的：多次传入相同的输入必须产生相同的输出。它不应做有副作用的操作，如 API 调用或路由跳转。这些应该在 dispatch action 前发生。

#### 3.根 reducer 应该把多个子 reducer 输出合并成一个单一的 state 树 ####

根 reducer 的结构完全由你决定。Redux 原生提供combineReducers()辅助函数，来把根 reducer 拆分成多个函数，用于分别处理 state 树的一个分支。

下面演示 combineReducers() 如何使用。假如你有两个 reducer：一个是 todo 列表，另一个是当前选择的过滤器设置：
``` js
 function todos(state = [], action) {
   // 省略处理逻辑...
   return nextState
 }

 function visibleTodoFilter(state = 'SHOW_ALL', action) {
   // 省略处理逻辑...
   return nextState
 }

 let todoApp = combineReducers({
   todos,
   visibleTodoFilter
 })
 ```
当你触发 action 后，combineReducers 返回的 todoApp 会负责调用两个 reducer：
 ``` js
 let nextTodos = todos(state.todos, action)
 let nextVisibleTodoFilter = visibleTodoFilter(state.visibleTodoFilter, action)
 ```
然后会把两个结果集合并成一个 state 树：
 ``` js
 return {
   todos: nextTodos,
   visibleTodoFilter: nextVisibleTodoFilter
 }
 ```
虽然 combineReducers() 是一个很方便的辅助工具，你也可以选择不用；你可以自行实现自己的根 reducer！

#### 4.Redux store 保存了根 reducer 返回的完整 state 树 ####

这个新的树就是应用的下一个 state！所有订阅 store.subscribe(listener) 的监听器都将被调用；监听器里可以调用 store.getState() 获得当前 state。

现在，可以应用新的 state 来更新 UI。如果你使用了 React Redux 这类的绑定库，这时就应该调用 component.setState(newState) 来更新。

### ** Redux源码解析 ** ###
#### ** 1.createStore解析 ** ####
``` jsx
import $$observable from 'symbol-observable'

import ActionTypes from './utils/actionTypes'
import isPlainObject from './utils/isPlainObject'

export default function createStore(reducer, preloadedState, enhancer) {
  // 如果 preloadedState和enhancer都为function，不支持，throw new Error
  // 我们都知道[initState]为object， [enhancer]为function, typeof arguments[3] === 'function'
  // 则抛出使用compose(),组合到一起, Store enhancer 是一个组合 store creator 的高阶函数，返回一个新的强化过的 store creator
  if (
    (typeof preloadedState === 'function' && typeof enhancer === 'function') ||
    (typeof enhancer === 'function' && typeof arguments[3] === 'function')
  ) {
    throw new Error(
      'It looks like you are passing several store enhancers to ' +
      'createStore(). This is not supported. Instead, compose them ' +
      'together to a single function'
    )
  }
  // preloadedState为function enhancer为undefined的时候说明initState没有初始化, 但是有middleware
  if (typeof preloadedState === 'function' && typeof enhancer === 'undefined') {
    enhancer = preloadedState   // 把 preloadedState 赋值给 enhancer
    preloadedState = undefined  // preloadedState赋值undeifined
  }
  // 如果参数enhancer存在
  if (typeof enhancer !== 'undefined') {
    // 如果enhancer存在，那他必须是个function, 否则throw Error
    if (typeof enhancer !== 'function') {
      throw new Error('Expected the enhancer to be a function.')
    }

    return enhancer(createStore)(reducer, preloadedState)
  }
  // 期待中的reducer是一个function
  if (typeof reducer !== 'function') {
    throw new Error('Expected the reducer to be a function.')
  }

  let currentReducer = reducer  // 临时的reducer
  let currentState = preloadedState // 临时的 init state
  let currentListeners = []   // 监听队列和观察者模式
  let nextListeners = currentListeners  // 浅拷贝这个队列
  let isDispatching = false  // 我们很容易先假设isDispatching标志是否正在执行dispatch
  
  // 先看下各个函数的名字， 打眼一看getState，dispatch，subscribe都是比较熟悉的api
  // subscribe，observable再加上定义的数组，应该肯定是监听队列和观察者模式

  // 其实这里是保存一份订阅快照
  function ensureCanMutateNextListeners() {
    //  不要忘了let nextListeners = currentListeners // 浅拷贝下这个队列
    // 判断nextListeners和当前的currentListeners是不是一个引用
    if (nextListeners === currentListeners) {
      // 如果是一个引用的话深拷贝出来一个currentListeners赋值给nextListener
      nextListeners = currentListeners.slice()
    }
  }

  function getState() {
    // dispatch中不可以getState, 为什么？
    // 因为dispatch是用来改变state的,为了确保state的正确性(获取最新的state)，所有要判断啦
    if (isDispatching) {
      throw new Error(
        'You may not call store.getState() while the reducer is executing. ' +
          'The reducer has already received the state as an argument. ' +
          'Pass it down from the top reducer instead of reading it from the store.'
      )
    }
    // 确定currentState是当前的state 看 -> subscribe
    return currentState
  }
  // store.subscribe方法设置监听函数，一旦触发dispatch，就自动执行这个函数
  // listener是一个callback function
  function subscribe(listener) {
    // 期望是个listener是个函数
    if (typeof listener !== 'function') {
      throw new Error('Expected the listener to be a function.')
    }
    // 同理不可以dispatch中
    if (isDispatching) {
      throw new Error(
        'You may not call store.subscribe() while the reducer is executing. ' +
          'If you would like to be notified after the store has been updated, subscribe from a ' +
          'component and invoke store.getState() in the callback to access the latest state. ' +
          'See https://redux.js.org/api-reference/store#subscribe(listener) for more details.'
      )
    }
    // 猜测是订阅标记, 用来标记是否有listener
    let isSubscribed = true
    // 什么意思, 点击进去看看
    ensureCanMutateNextListeners()
    // push一个function，明显的观察者模式，添加一个订阅函数
    nextListeners.push(listener)
    // 返回取消的function（unsubscribe）
    return function unsubscribe() {
      // 没有listener直接返回
      if (!isSubscribed) {
        return
      }
      // 同理不可以dispatch中
      if (isDispatching) {
        throw new Error(
          'You may not unsubscribe from a store listener while the reducer is executing. ' +
            'See https://redux.js.org/api-reference/store#subscribe(listener) for more details.'
        )
      }

      isSubscribed = false
      // 保存快照
      ensureCanMutateNextListeners()
      // 找到并删除当前的listener
      const index = nextListeners.indexOf(listener)
      nextListeners.splice(index, 1)
    }
  }
  // 发送一个action
  function dispatch(action) {
    // 看下util的isPlainObject
    // acticon必须是由Object构造的函数， 否则throw Error
    if (!isPlainObject(action)) {
      throw new Error(
        'Actions must be plain objects. ' +
          'Use custom middleware for async actions.'
      )
    }
    // 判断action, 不存在type throw Error
    if (typeof action.type === 'undefined') {
      throw new Error(
        'Actions may not have an undefined "type" property. ' +
          'Have you misspelled a constant?'
      )
    }
    // dispatch中不可以有进行的dispatch
    if (isDispatching) {
      throw new Error('Reducers may not dispatch actions.')
    }

    try {
      // 执行时的标记
      isDispatching = true
      // 执行reducer， 来，回忆一下reducer，参数state， action 返回值newState
      // 这就是dispatch一个action可以改变全局state的原因
      currentState = currentReducer(currentState, action)
    } finally {
      // 最终执行， isDispatching标记为false， 即完成状态
      isDispatching = false
    }
    // 所有的的监听函数赋值给 listeners
    const listeners = (currentListeners = nextListeners)
    for (let i = 0; i < listeners.length; i++) {
      const listener = listeners[i]
      // 执行每一个监听函数
      listener()
    }
    // 返回传入的action
    return action
  }
  // 到这里dispatch方法就结束了， 我们来思考总结一下， 为什么要用listeners
  // 当dispatch发送一个规范的action时，会更新state
  // 但是state改变了之后我们需要做一些事情， 比如更新ui既数据驱动视图
  // 所以要提供一个监听模式，当然还要有一个监听函数subscribe, 保证dispatch和subscribe之间的一对多的模式

  /* 替换store当前使用的reducer函数
   * 如果你的应用程序实现了代码拆分并且你希望动态加载某些reducer的时候你
   * 可能会用到这个方法。或者当你要为Redux实现一个热加载机制的时候，你也
   * 会用到它
   */
  function replaceReducer(nextReducer) {
    // 期望nextReducer是个function
    if (typeof nextReducer !== 'function') {
      throw new Error('Expected the nextReducer to be a function.')
    }
    // 当前的currentReducer更新为参数nextReducer
    currentReducer = nextReducer
    // 发送一个dispatch初始化state，表明一下是REPLACE
    dispatch({ type: ActionTypes.REPLACE })
  }

  function observable() {
    // 首先保留对Redux中subscribe方法的引用，在observable的世界里
    const outerSubscribe = subscribe
    return {
      /**
       * 一个极简的observable订阅方法。
       * @param {Object} observer 任何可以作为observer使用的对象
       * observer对象应该包含一个`next`方法。
       * @returns {subscription} 返回一个带有`unsbscribe`方法的对象。该
       * 方法将用于停止接收来自store的状态变更信息。
       */
      subscribe(observer) {
        // 参数为object
        if (typeof observer !== 'object' || observer === null) {
          throw new TypeError('Expected the observer to be an object.')
        }
        // 创建一个状态变更回调函数。逻辑很简单，把store最新的状态传给observer
        function observeState() {
          if (observer.next) {
            observer.next(getState())
          }
        }
        // 立即执行一次回调函数，把当前状态传给observer
        observeState()
        const unsubscribe = outerSubscribe(observeState)
        return { unsubscribe }
      },
      // 根据observable提案，[Symbol.observable]()返回observable对象自身
      [$$observable]() {
        return this
      }
    }
  }
  // dispatch初始化state
  dispatch({ type: ActionTypes.INIT })

  return {
    dispatch,
    subscribe,
    getState,
    replaceReducer,
    [$$observable]: observable
  }
}

```

#### ** 2.applyMiddleware解析 ** ####

``` jsx
import compose from './compose'

export default function applyMiddleware(...middlewares) {
  // 返回名为createStore的函数, 回应createStore中的enhancer(createStore)(reducer, preloadedState)
  return createStore => (...args) => {
    // 保存createStore(reducer, initstate) || createStore(reducer), 赋值给store
    const store = createStore(...args)
    // 定义了一个dispatch， 调用会 throw new Error(dispatching虽然构造middleware但不允许其他middleware应用)
    // 作用是在dispatch改造完成前调用dispatch只会打印错误信息
    let dispatch = () => {
      throw new Error(
        `Dispatching while constructing your middleware is not allowed. ` +
          `Other middleware would not be applied to this dispatch.`
      )
    }
    // 定义middlewareAPI, 中间件中的store
    const middlewareAPI = {
      // add getState
      getState: store.getState, 
      // 添加dispatch并包装一个function， 参数为(reducer, [initstate])
      // 向下看一看middlewareAPI作为参数被回调回去，不难理解, 告诉dispath不能再middleware插件中构造
      dispatch: (...args) => dispatch(...args)
    }
    // 调用每一个这样形式的middleware = store => next => action =>{}, 
    // 组成一个这样[f(next)=>acticon=>next(action)...]的array，赋值给chain
    // 调用数组中的每个中间件函数，得到所有的改造函数
    /*假设有[a,b,c]三个middleware，他们都长这样：
    ({ dispatch, getState }) => next => action => {
      // 对action的操作
      return next(action)
    }
    那么，c会最先接收到一个参数，就是store.dispatch,作为它的next。然后c使用闭包将这个next存起来，
    把自己作为下一个middlewareb的next参数传入。这样，就将所有的middleware串起来了。最后，
    如果用户dispatch一个action，那么执行顺序会是: c --> b --> a
    */
    const chain = middlewares.map(middleware => middleware(middlewareAPI))
    // compose(...chain)会形成一个调用链, next指代下一个函数的注册, 这就是中间件的返回值要是next(action)的原因
    // 如果执行到了最后next就是原生的store.dispatch方法
    // 将这些改造函数compose成一个函数
    // 用compose后的函数去改造store的dispatch
    dispatch = compose(...chain)(store.dispatch)
    // 返回增强的store, dispatch
    return {
      ...store,
      dispatch
    }
  }
}
```

#### ** 3.combineReducers解析 ** ####

``` jsx
import ActionTypes from './utils/actionTypes'
import warning from './utils/warning'
import isPlainObject from './utils/isPlainObject'

function getUndefinedStateErrorMessage(key, action) {
  const actionType = action && action.type
  const actionDescription =
    (actionType && `action "${String(actionType)}"`) || 'an action'

  return (
    `Given ${actionDescription}, reducer "${key}" returned undefined. ` +
    `To ignore an action, you must explicitly return the previous state. ` +
    `If you want this reducer to hold no value, you can return null instead of undefined.`
  )
}

function getUnexpectedStateShapeWarningMessage(
  inputState,
  reducers,
  action,
  unexpectedKeyCache
) {
  const reducerKeys = Object.keys(reducers)
  const argumentName =
    action && action.type === ActionTypes.INIT
      ? 'preloadedState argument passed to createStore'
      : 'previous state received by the reducer'

  if (reducerKeys.length === 0) {
    return (
      'Store does not have a valid reducer. Make sure the argument passed ' +
      'to combineReducers is an object whose values are reducers.'
    )
  }

  if (!isPlainObject(inputState)) {
    return (
      `The ${argumentName} has unexpected type of "` +
      {}.toString.call(inputState).match(/\s([a-z|A-Z]+)/)[1] +
      `". Expected argument to be an object with the following ` +
      `keys: "${reducerKeys.join('", "')}"`
    )
  }

  const unexpectedKeys = Object.keys(inputState).filter(
    key => !reducers.hasOwnProperty(key) && !unexpectedKeyCache[key]
  )

  unexpectedKeys.forEach(key => {
    unexpectedKeyCache[key] = true
  })

  if (action && action.type === ActionTypes.REPLACE) return

  if (unexpectedKeys.length > 0) {
    return (
      `Unexpected ${unexpectedKeys.length > 1 ? 'keys' : 'key'} ` +
      `"${unexpectedKeys.join('", "')}" found in ${argumentName}. ` +
      `Expected to find one of the known reducer keys instead: ` +
      `"${reducerKeys.join('", "')}". Unexpected keys will be ignored.`
    )
  }
}
// 很明显assertReducerShape是用于reducer的规范
function assertReducerShape(reducers) {
  Object.keys(reducers).forEach(key => {
    const reducer = reducers[key]
    const initialState = reducer(undefined, { type: ActionTypes.INIT })

    if (typeof initialState === 'undefined') {
      throw new Error(
        `Reducer "${key}" returned undefined during initialization. ` +
          `If the state passed to the reducer is undefined, you must ` +
          `explicitly return the initial state. The initial state may ` +
          `not be undefined. If you don't want to set a value for this reducer, ` +
          `you can use null instead of undefined.`
      )
    }

    if (
      typeof reducer(undefined, {
        type: ActionTypes.PROBE_UNKNOWN_ACTION()
      }) === 'undefined'
    ) {
      throw new Error(
        `Reducer "${key}" returned undefined when probed with a random type. ` +
          `Don't try to handle ${
            ActionTypes.INIT
          } or other actions in "redux/*" ` +
          `namespace. They are considered private. Instead, you must return the ` +
          `current state for any unknown actions, unless it is undefined, ` +
          `in which case you must return the initial state, regardless of the ` +
          `action type. The initial state may not be undefined, but can be null.`
      )
    }
  })
}

// 用于合并reducer 一般是这样combineReducers({a,b,c})
export default function combineReducers(reducers) {
  // reducers中key的数组
  const reducerKeys = Object.keys(reducers)
  // 最终的reducer
  const finalReducers = {}
  for (let i = 0; i < reducerKeys.length; i++) {
    const key = reducerKeys[i]

    if (process.env.NODE_ENV !== 'production') {
      if (typeof reducers[key] === 'undefined') {
        warning(`No reducer provided for key "${key}"`)
      }
    }
    // reducer要是一个function
    if (typeof reducers[key] === 'function') {
       // 赋值给finalReducers
      finalReducers[key] = reducers[key]
    }
  }
  // 符合规范的reducer的key数组
  const finalReducerKeys = Object.keys(finalReducers)
  // 意想不到的key， 先往下看看
  let unexpectedKeyCache
  if (process.env.NODE_ENV !== 'production') {
    unexpectedKeyCache = {}
  }

  let shapeAssertionError
  try {
    assertReducerShape(finalReducers)
  } catch (e) {
    shapeAssertionError = e
  }
  // 返回function， 即为createstore中的reducer参数既currentreducer
  // 自然有state和action两个参数， 可以回createstore文件看看currentReducer(currentState, action)
  return function combination(state = {}, action) {
    // reducer不规范报错
    if (shapeAssertionError) {
      throw shapeAssertionError
    }

    if (process.env.NODE_ENV !== 'production') {
      const warningMessage = getUnexpectedStateShapeWarningMessage(
        state,
        finalReducers,
        action,
        unexpectedKeyCache
      )
      if (warningMessage) {
        warning(warningMessage)
      }
    }
    // 状态变化的标志
    let hasChanged = false
    const nextState = {}
    for (let i = 0; i < finalReducerKeys.length; i++) {
      // 获取finalReducerKeys的key和value（function）
      const key = finalReducerKeys[i]
      const reducer = finalReducers[key]
      // 当前key的state值
      const previousStateForKey = state[key]
      // 执行reducer， 返回当前state
      const nextStateForKey = reducer(previousStateForKey, action)
      // 不存在返回值报错
      if (typeof nextStateForKey === 'undefined') {
        const errorMessage = getUndefinedStateErrorMessage(key, action)
        throw new Error(errorMessage)
      }
      // 新的state放在nextState对应的key里
      nextState[key] = nextStateForKey
      // 判断新的state是不是同一引用， 以检验reducer是不是纯函数
      hasChanged = hasChanged || nextStateForKey !== previousStateForKey
    }
    // 改变了返回nextState
    return hasChanged ? nextState : state
  }
}
```

#### ** 4.bindActionCreator解析 ** ####

``` jsx
function bindActionCreator(actionCreator, dispatch) {
  // 闭包
  return function() {
    // 执行后返回结果为传入的actionCreator直接调用arguments
    return dispatch(actionCreator.apply(this, arguments))
  }
}

export default function bindActionCreators(actionCreators, dispatch) {
  // actionCreators为function
  if (typeof actionCreators === 'function') {
    return bindActionCreator(actionCreators, dispatch)
  }

  if (typeof actionCreators !== 'object' || actionCreators === null) {
    throw new Error(
      `bindActionCreators expected an object or a function, instead received ${
        actionCreators === null ? 'null' : typeof actionCreators
      }. ` +
        `Did you write "import ActionCreators from" instead of "import * as ActionCreators from"?`
    )
  }
  
  // objec 为对象时, object 转为数组
  const keys = Object.keys(actionCreators)
  // 定义return 的props
  const boundActionCreators = {}
  for (let i = 0; i < keys.length; i++) {
    // actionCreators的key 通常为actionCreators function的name（方法名）
    const key = keys[i]
    // function => actionCreators工厂方法本身
    const actionCreator = actionCreators[key]
    if (typeof actionCreator === 'function') {
      // 判断每个键在原始对象中的值是否是个函数，如果是一个函数则认为它是一个动作工厂，
      // 并使用bindActionCreator函数来封装调度过程，最后把生成的新函数以同样的键key存储到boundActionCreators对象中。
      // 在函数的末尾会返回boundActionCreators对象
      boundActionCreators[key] = bindActionCreator(actionCreator, dispatch)
    }
  }
  // return 的props
  return boundActionCreators
}

```

#### ** 5.compose解析 ** ####

``` jsx
//Composes functions from right to left.

export default function compose(...funcs) {
  if (funcs.length === 0) {
    return arg => arg
  }

  if (funcs.length === 1) {
    return funcs[0]
  }

  return funcs.reduce((a, b) => (...args) => a(b(...args)))
}

//like this
compose(funcA, funcB, funcC) === compose(funcA(funcB(funcC())))
```
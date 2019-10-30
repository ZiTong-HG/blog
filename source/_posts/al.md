---
title: React-Redux在React中的应用
date: 2019-01-11 19:23:07
categories: React
tags:
  - react
  - javascript
---
前面一篇文章我们分析了下Redux, 现在分析下React-Redux, React Redux 事实上是两个独立的产品， 
应用可以使用 React 而不使用Redux ，也可以使用 Redux 而不使用 React ，但是，如果两者结合使用，没有理由不使用一个名叫 react-redux 的库这个库能够大大简化代码的书写, <!--more--> 我们先看一官网redux的经典案例, 从而进一步了解react-redux。

### ** Redux的经典案例  ** ###
经典案例加减
+ 定义reducer函数根据action的类型改变state
+ actions 定义指令
+ 通过createStore创建store
+ 调用store.dispatch()发出修改state的命令

``` jsx
import { createStore } from 'redux'

const reducer = (state = {count: 0}, action) => {
  switch (action.type){
    case 'INCREASE': return {count: state.count + 1};
    case 'DECREASE': return {count: state.count - 1};
    default: return state;
  }
}

const actions = {
  increase: () => ({type: 'INCREASE'}),
  decrease: () => ({type: 'DECREASE'})
}

const store = createStore(reducer);

// 监听每一个dispatch后返回当前最新的state
store.subscribe(() =>
  console.log(store.getState())
);

store.dispatch(actions.increase()) // {count: 1}
store.dispatch(actions.increase()) // {count: 2}
store.dispatch(actions.increase()) // {count: 3}
```

现在可以运用到React Component中了, 来看看吧

``` jsx
class Add extends Component {
  render() {
    return <div onClick={ () => store.dispatch(actions.addTodo()) }>Add</div>
  }
}
```
### ** React-Redux ** ###
Official React bindings for Redux.Performant and flexible
(Redux 官方提供的 React 绑定库。 具有高效且灵活的特性。)

** react-redux 的两个最主要功能：**

connect ：连接数据处理组件和内部UI组件；
Provider ：提供包含 store的context

![al](/images/react-redux.png)
先来看看使用react-redux后的效果吧！

``` jsx
import { connect } from 'react-redux'

// 装饰器写法, 不懂的可以去脑补一下
@connect(
  state  => state,
  action
)
class Add extends Component {
  render() {
    return <div onClick={ () => this.props.addTodo()) }>Add</div>
  }
}

// 与装饰器一个意思的写法
export default connect(
  state => state,
  action
)
```

### ** Provider源码解析 ** ###
Provider 能拿到关键的store并传递给每个子组件

``` jsx
class Provider extends Component {
  getChildContext() {
    return { [storeKey]: this[storeKey], [subscriptionKey]: null }
  }

  constructor(props, context) {
    super(props, context)
    this[storeKey] = props.store;
  }

  render() {
    return Children.only(this.props.children)
  }
}
```
即通过context api将store传到子组件里面去。


### ** connect源理简化解析 ** ###
connect() 接收四个参数, 它们分别是 mapStateToProps, mapDispatchToProps, mergeProps和options.

mapStateToProps是一个函数，接受state并且返回一个对象，对象包括要传递给组件的属性，这里我们可以对state做筛选与过滤。因为我们只需要全局数据的部分数据传递给组件。

``` jsx
// 例子来源Todo
function mapStateToProps(state) {
  return {
    visibleTodos: selectTodos(state.todos, state.visibilityFilter),
    visibilityFilter: state.visibilityFilter
  }
}
```
mapDispatchToProps同样也是一个函数，返回要传递给组件的函数对象。

``` jsx
// actions.js
export function addTodo(text) {
  return { type: ADD_TODO, text }
}

export function completeTodo(index) {
  return { type: COMPLETE_TODO, index }
}

export function setVisibilityFilter(filter) {
  return { type: SET_VISIBILITY_FILTER, filter }
}

export default {
  addTodo, completeTodo, setVisibilityFilter,
}

// App.js
function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(actions, dispatch) }
}
```

mergeProps和options目前用的少, 暂不叙述

``` jsx
export default function(mapStateToProps,mapDispatchToProps){
  return function(WrapedComponent){
    class ProxyComponent extends Component{
      static contextTypes = {
        store:propTypes.object
      }
      constructor(props,context){
        super(props,context);
        this.store = context.store;
        this.state = mapStateToProps(this.store.getState());
      }
      componentWillMount(){
        this.unsubscribe = this.store.subscribe(()=>{
          this.setState(mapStateToProps(this.store.getState()));
        });
      }
      componentWillUnmount(){
        this.unsubscribe();
      }
      render(){
        let actions= {};
        if(typeof mapDispatchToProps == 'function'){
          actions = mapDispatchToProps(this.store.disaptch);
        }else if(typeof mapDispatchToProps == 'object'){
          actions = bindActionCreators(mapDispatchToProps,this.store.dispatch);
        }
        return <WrapedComponent {...this.state} {...actions}/>
     }
  }
  return ProxyComponent;
 }
}
```
** 1.state的返回 **
connect中对于Provided父组件上传来的store,通过将状态返回

``` jsx
mapStateToProps(this.store.getState());
```
** 2.通过 Redux 的辅助函数 bindActionCreators()，用dispatch监听每一个action。 **

``` jsx
 bindActionCreators(mapDispatchToProps,this.store.dispatch);
```
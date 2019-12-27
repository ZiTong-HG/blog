---
title: React组件通信问题
categories: React
date: 2019-1-5 1:20:36
tags: 
 - react
---

在使用 React 的过程中，不可避免的需要组件间进行消息传递（通信），组件间通信大体有下面几种情况：
父组件向子组件通信,子组件向父组件通信,跨级组件之间通信,非嵌套组件间通信,下面依次说下这几种通信方式。<!-- more -->

### 1.父组件传递值给子组件 ###
想必这种大家都是知道的吧！都想到了用我们react中的props,那么我在这简单的写了小demo,请看

父组件
``` jsx
    class Parent extends Component{
      render() {
        return (
          <Child text="Hello" />
        )
      }
    }
```
子组件
``` jsx
    class Child extends Component{
      render(){
        return (
          <p>{ this.props.text }</p>
        )
      }
    }
```
### 2.子组件传值给父组件 ### 
相必大家在这里估计得想一想吧！那么由我同样写个小demo来告诉大家,理解了其实也不难哦
父组件

``` jsx
    class Parent extends Component {
      constructor(props) {
        super(props); 
        this.state = {
          someKey: 'world'
        };
      }
      fn(newState) {
        this.setState({ someKey: newState });
      }
      render() {
        return (
          <div>
            <Child pfn={this.fn.bind(this)} />
            <p>{this.state.someKey}</p>
          </div>
        );
      }
    }
```
子组件

``` jsx
    class Child extends Component {
      constructor(props) {
        super(props); 
        this.state = {
          newState: 'Hello'
        };
      }
      someFn() {
        this.props.pfn(this.state.newState);//这里就是传值给父组件
      }
      render() {
        return (
          <div onClick={ this.someFn.bind(this) }>点我</div>
        );
      }
    }
```
通过回调函数进行向父组件传值，并绑定父组件的this this.fn.bind(this)

### 3.有任何嵌套关系的组件之间传值 ###
如果组件之间没有任何关系，组件嵌套层次比较深（个人认为 2 层以上已经算深了），或者你为了一些组件能够订阅、写入一些信号，不想让组件之间插入一个组件，让两个组件处于独立的关系。对于事件系统，这里有 2 个基本操作步骤：订阅（subscribe）/监听（listen）一个事件通知，并发送（send）/触发（trigger）/发布（publish）/发送（dispatch）一个事件通知那些想要的组件。

下面讲介绍 3 种模式来处理事件，你能 点击这里 来比较一下它们。

简单总结一下：

#### (1) Event Emitter/Target/Dispatcher ####

特点：需要一个指定的订阅源
``` jsx
    // to subscribe
    otherObject.addEventListener(‘click’, function() { alert(‘click!’); });
    // to dispatch
    this.dispatchEvent(‘click’);
```
#### (2) Publish / Subscribe #### 

特点：触发事件的时候，你不需要指定一个特定的源，因为它是使用一个全局对象来处理事件（其实就是一个全局广播的方式来处理事件）
``` jsx
    // to subscribe
    globalBroadcaster.subscribe(‘click’, function() { alert(‘click!’); });
    // to dispatch
    globalBroadcaster.publish(‘click’);
```
#### (3) Signals #### 

特点：与Event Emitter/Target/Dispatcher相似，但是你不要使用随机的字符串作为事件触发的引用。触发事件的每一个对象都需要一个确切的名字（就是类似硬编码类的去写事件名字），并且在触发的时候，也必须要指定确切的事件。（看例子吧，很好理解）
``` jsx
    // to subscribe
    otherObject.clicked.add(function() { alert(‘click’); });
    // to dispatch
    this.clicked.dispatch();
```
在处理事件的时候，需要注意：
在 componentDidMount 事件中，如果组件挂载（mounted）完成，再订阅事件；当组件卸载（unmounted）的时候，在 componentWillUnmount 事件中取消事件的订阅。

看了上面所述,是否有所感悟
例如通过事件来进行非父子组件间的通信，如果操作不是很多，我们可以自己动手简单实现以下哦！
下面我简单的写了一个,请看

### 4.简单实现了一下 subscribe 和 dispatch ###

``` jsx
    let EventEmitter = {
      _events: {},
      dispatch: function (event, data) {
        if (!this._events[event]) { // 没有监听事件
          return;
        }
        for (var i = 0; i < this._events[event].length; i++) {
          this._events[event][i](data);
        }
      },
      subscribe: function (event, callback) {
        // 创建一个新事件数组
        if (!this._events[event]) {
          this._events[event] = [];
        }
        this._events[event].push(callback);
      }
    };

    otherObject.subscribe('namechanged', (data) => console.log(data.name));
    this.dispatch('namechanged', { name: 'John' });
```
是不是现在觉得组件通信其实也没那么难懂吧,加油吧，骚年
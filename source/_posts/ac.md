---
title: Vue组件通信问题
date: 2018-12-7 11:18:37
categories: Vue
tags:
 - vue
 - javascript
 - html
---

### ** 子组件给父组件通信 ** ###
如果子组件想要改变数据呢？这在vue中是不允许的，因为vue只允许单向数据传递，这时候我们可以通过触发事件来通知父组件改变数据，从而达到改变子组件数据的目的<!-- more -->

子组件：
``` html
<template>
  <div @click='upData'></div>  
</template>
```
``` js
<script type="text/javascript">
  export default {
    data () {
      return {
        msg: 'Hello'
      }
    }    
    methods: {
      upData () {
        this.$emit('childData', this.msg) //this.msg传递的数据
      }
    }
  }
</script>
```
``` css
<style type="text/css">
</style>
```
通过绑定事件upData,在里面使用$emit事件来注册childData事件,并且传递数值this.msg到父组件中 
父组件：
``` html
<template>
  <child @upData='changData' :msg='msg'></child>  //监听子组件触发的事件,然后调用change方法
</template>
```
``` js
<script type="text/javascript">
  export default {
    data () {
      return {
        msg: ''
      }
    }    
    methods: {
      changData (msg) {
        this.msg = msg
      }
    }
  }
</script>
```
``` css
<style type="text/css">
</style>
```
父组件通过监听子组件的childData的事件,来触发自己的绑定的changData事件,并将值获取复制给自己的msg
到这里就完成了子组件给父组件传递数据的过程

### ** 子组件给父组件通信 ** ###

父组件数据如何传递给子组件呢？可以通过props属性来实现

例子如下
父组件：
``` html
<template>
  <parent>
    <child :child-msg='msg'></child> //注意其中childmsg需分开写出来child-msg
  </parent>    
</template>
```
``` js
<script type="text/javascript">
  export default {
    data () {
      return {
        msg: 'Hello'    //定一个传递的变量msg
      }
    }    
  }
</script>
```
``` css
<style type="text/css">    
</style>
```
子组件通过props来接收数据:
方式1：

``` js
props: ['childMsg']
```
此处的props中的数值，需要与父组件中使用子组件：child-msg一致,
否则,传递不成功

方式2 :

``` js
props: {
  childMsg: Array //这样可以指定传入的类型，如果类型不对，会警告
}
```
检测props中传递的值的类型,不对则会提示警告

方式3：

``` js
props: {
  childMsg: {
    type: Array,
    default: [0,0,0] //这样可以指定默认的值
  }
} 
```
在props中你可对接收的数值，进行验证,同样也可以设置默认值,
以方便数据的的准确性,这样呢，就实现了父组件向子组件传递数据.

 ### ** 非父子组件之间的通信 ** ###

如果不是父子组件需要通信,那将怎样实现呢?
首先我们需要创建一个事件中心,通过事件中心来接收或者传递事件,作为一个中转站

#### 1.创建事件中心 ####
``` js      
let eventControl = new Vue();
```
#### 2.组件1触发事件 ####
``` html
<template>
  <div @pubEvent="changeData"></div>  //监听组件触发的事件,然后调用changeData方法
</template>
```
``` js
<script type="text/javascript">
  export default {
    data () {
      return {
      }
    }    
    methods: {
      changData () {
        eventControl.$emit('changTo', 'msg') //触发事件中心,以及需要传递的事件
      }
    }
  }
</script>
```
``` css
<style type="text/css">
</style>
```
此时此刻已完成需要的事件的添加到了中转站,触发事件已经完成

#### 3.组件2接收触发事件 ####
``` html
<template>
  <div></div>
</template>
```
``` js
<script type="text/javascript">
  export default {
    data () {
      return {
        msg: ''
      }
    }    
    create () {
      eventControl.$on('changTo', () => {
        this.msg = msg                     //接收触发事件中心 
      }) 
    }
  }
</script>
```
``` css
<style type="text/css">
</style>
```
此时此刻已完成接收事件的监听在中转站,接收事件已经完成,当触发事件被点击的,则中转站中的接收事件
会监听到,从而完成费父子组件间的通信,进行传递msg信息

#### 4.自定义事件传递信息这里不做阐述,方法会较为复杂,需要了解的可以观看官方Api,谢谢 ####
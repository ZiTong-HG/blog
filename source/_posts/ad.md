---
title: Vue非父子组件之间的通信
date: 2018-12-14 11:20:07
categories: Vue
tags:
 - vue
 - javascript
 - html
---

Vue非父子组件之间的通信
如果不是父子组件需要通信,那将怎样实现呢?<!-- more -->
首先我们需要创建一个事件中心,通过事件中心来接收或者传递事件,作为一个中转站

### 1.创建事件中心 ###
``` js      
    let eventControl = new Vue();
```
### 2.组件1触发事件 ###
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

### 3.组件2接收触发事件 ### 
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

### 4.自定义事件传递信息这里不做阐述,方法会较为复杂,需要了解的可以观看官方Api,谢谢 ###

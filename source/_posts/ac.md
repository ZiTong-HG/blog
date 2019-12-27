---
title: Vue子组件给父组件通信
date: 2018-12-7 11:18:37
categories: Vue
tags:
 - vue
 - javascript
 - html
---

子组件给父组件通信
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
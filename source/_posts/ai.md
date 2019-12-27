---
title: Vue父组件传递数据给子组件
date: 2019-1-19 17:20:15
categories: Vue
tags: 
 - vue
 - javascript
 - html
---
父组件传递数据给子组件
父组件数据如何传递给子组件呢？可以通过props属性来实现<!-- more -->

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
---
title: Css中的大于号('>')你可知？
date: 2018-11-30 11:05:59
categories: Css
tags:
 - css
 - javascript
 - html
---

继承这个词,相信大家不会陌生,那么今天说点大于号('>')与
继承的关系,所以需更深的原理,来看一下吧！<!-- more -->

看一下这个代码
``` html
      <div>
          <span>11111</span>
          <span>22222</span>
          <span>33333</span>
      </div>
```
``` css
      <style type="text/css">
          div > span {
              font-size: 20px;
              background: blue;
          }
      </style>
```
此时会是什么样子,大家应该了解吧

如果要是使第一个span不同于后面两个呢？怎样解决，这样吗？
``` html
    <div>
        <p>
          <span>11111</span>
        </p>
        <span>22222</span>
        <span>33333</span>
    </div>
```
这样确实可以,所以大于号('>')是在嵌套标签中，将样式只作用于儿子辈的标签，而不作用于孙子辈的标签。

但如果这样呢?
``` html
    <div>
        <span>
            <span>11111</span>
        </span>
        <span>22222</span>
        <span>33333</span>
    </div>
```
此时大于号会起作用吗？答案:不会.因为这个孙子辈的span标签继承儿子辈的span标签样式。

<!DOCTYPE html>
<html>
<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<head>
    <meta charset="UTF-8">
    <title>用户注册</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/layui/css/layui.css" type="text/css" charset="UTF-8"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/st-style.css" type="text/css" charset="UTF-8"/>
    <script src="https://libs.baidu.com/jquery/2.1.4/jquery.min.js" charset="UTF-8"></script>
    <script src="${pageContext.request.contextPath}/static/layui/layui.all.js" charset="UTF-8"></script>
    <script type="text/javascript">
        $(function () {
            //给退出按钮绑定事件
            $("#logout").click(function () {
               $.ajax({
                   url:"http://localhost:8080/logout",
                   type:"get",
                   dataType:"json",
                   success:function () {
                       window.location.reload();
                   },
                   error:function () {
                       window.location.reload();
                   }
               })
            });

            //给登录按钮绑定事件
            $("#login_btn").click(function () {
                var id = $("#login_id").val().trim();
                var password = $("#login_password").val().trim();
                if(id==="" ||password === ""){
                    layer.open({
                        title: '登录失败',
                        content: '用户名和密码不得为空',
                        shade: 0.5,
                        yes: function(){
                            layer.closeAll();
                        }
                    });
                }else{
                    //验证合法
                    $.ajax({
                        url: "http://localhost:8080/login",
                        type: "post",
                        data: {"id": id,"password":password},
                        dataType: "json",
                        success: function (result) {
                            //如果查询成功
                            console.log(result.data);
                            if (result.status == 0) {
                                window.location.href = "/home";
                            } else {
                                layer.open({
                                    title: '登录失败',
                                    content: '请检查用户名和密码',
                                    shade: 0.5,
                                    yes: function(){
                                        layer.closeAll();
                                    }
                                });
                            }
                        },
                        error: function () {
                            alert("登录发生异常");
                        }
                    });
                }
            });

            //注册
            $("#reg_btn").click(function () {
                var id = $("#reg_id").val().trim();
                var password = $("#reg_password").val().trim();
                var password_again = $("#reg_password_again").val().trim();
                var name = $("#reg_name").val().trim();
                if(id.length < 5 ||password < 5 ) {
                    layer.open({
                        title: '注册失败',
                        content: '用户名和密码不得小于5位',
                        shade: 0.5,
                        yes: function () {
                            layer.closeAll();
                        }
                    });
                }
                else if(name===""){
                    layer.open({
                        title: '注册失败',
                        content: '名称不得为空',
                        shade: 0.5,
                        yes: function () {
                            layer.closeAll();
                        }
                    });
                }else{
                    $.ajax({
                        url: "http://localhost:8080/registerJ",
                        type: "post",
                        data: {"id": id,"password":password,"name":name},
                        dataType: "json",
                        success: function (result) {
                            //如果查询成功
                            console.log(result.data);
                            if (result.status == 0) {
                                layer.open({
                                    title: '注册成功',
                                    content: '欢迎你,'+result.data.name,
                                    shade: 0.5,
                                    yes: function(){
                                        layer.closeAll();
                                    }
                                });
                            } else {
                                layer.open({
                                    title: '注册失败',
                                    content: '注册失败',
                                    shade: 0.5,
                                    yes: function(){
                                        layer.closeAll();
                                    }
                                });
                            }
                        },
                        error: function () {
                            layer.open({
                                title: '注册成功',
                                content: '注册成功，请登录',
                                shade: 0.5,
                                yes: function(){
                                    window.location.href = "/";
                                }
                            });

                        }
                    });
                }
            })
        });
    </script>
</head>

<body>

<div class="st-banner" style="height: 250px"><a href="/home"> <img style="width: 200px;margin-top: 30px" src="${pageContext.request.contextPath}/static/image/album-banner.png" /></a></div>
<div class="st-banner" style="height: 100px">电 子 相 册</div>
<div class="layui-main" style="width:450px;text-align:center">
    <div class="layui-tab layui-tab-brief" style = "display:${sessionScope.isLogin?"none":"block"}" lay-filter="docDemoTabBrief">
        <ul class="layui-tab-title">
            <li class="layui-this" style="">登录</li>
            <li  style="">注册</li>
<%--            <li  style="">查询</li>--%>
        </ul>
        <div class="layui-tab-content">
            <%--登录--%>
            <div class="layui-tab-item layui-show">
                <form class="layui-form" style="margin-top:20px" method="post">
                    <div class="layui-form-item" style="text-align:center">
                        <div class="">
                            <input type="text" id="login_id" autocomplete="off" placeholder="请输入用户名" class="layui-input">
                        </div>
                    </div>

                    <div class="layui-form-item">
                        <div class="">
                            <input type="password" id="login_password" autocomplete="off" placeholder="请输入密码" class="layui-input">
                        </div>
                    </div>

                    <button type = "button" id="login_btn" style = "width:100%"class="layui-btn layui-btn-lg layui-btn-primary layui-btn-radius">登录</button>
                </form>
            </div>

            <%--注册--%>
            <div class="layui-tab-item">
                <form class="layui-form" style="margin-top:20px" method="post">
                    <div class="layui-form-item" style="text-align:center">
                        <div class="">
                            <input type="text"  id="reg_id" autocomplete="off" placeholder="请输入用户名" class="layui-input">
                        </div>
                    </div>

                    <div class="layui-form-item">
                        <div class="">
                            <input type="password" id="reg_password" autocomplete="off" placeholder="请输入密码" class="layui-input">
                        </div>
                    </div>

                    <div class="layui-form-item">
                        <div class="">
                            <input type="password" id="reg_password_again" autocomplete="off" placeholder="请再次输入密码" class="layui-input">
                        </div>
                    </div>

                    <div class="layui-form-item">
                        <div class="">
                            <input type="text" id="reg_name" autocomplete="off" placeholder="请输入昵称" class="layui-input">
                        </div>
                    </div>


                    <button type = "button" id="reg_btn" style = "width:100%"class="layui-btn layui-btn-lg layui-btn-primary layui-btn-radius">注册</button>
                </form>
            </div>
        </div>
    </div>
</div>
</body>
</html>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<html>
<head>
    <title>私信</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/layui/css/layui.css" type="text/css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/st-style.css" type="text/css"/>
    <script src="https://libs.baidu.com/jquery/2.1.4/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/static/layui/layui.all.js" charset="UTF-8"></script>
    <script type="text/javascript">
        $(function () {
            $("#send_btn").click(function () {
                var context = $("#send_context").val().trim();
                var toId = '${toId}';
                if (context.length == 0) {
                    layer.open({
                        title: '发送失败',
                        content: '发送内容不得为空',
                        shade: 0.5,
                        yes: function () {
                            layer.closeAll();
                        }
                    });
                } else {
                    $.ajax({
                        url: "http://localhost:8080/sendmessageS",
                        type: "post",
                        data: {"context": context, "toId": toId},
                        dataType: "json",
                        success: function (result) {
                            //如果查询成功
                            console.log(result.data);
                            if (result.status == 0) {
                                layer.open({
                                    title: '发送成功',
                                    content: '消息发送成功',
                                    shade: 0.5,
                                    yes: function () {
                                        layer.closeAll();
                                        window.location.href = "/me/messages";
                                    }
                                });
                            }
                        }
                    })
                }
            })
        });</script>
</head>
<body class="gray-color">
<div>
    <jsp:include page="header.jsp"></jsp:include>
    <form class="layui-form" style="background: white;margin: 0 auto;width: 850px;height: max-content">

        <div class="me-avatar content-center">
            <img src="/getAvatar?id=${toId}" width="150px"/>
        </div>

        <div class="layui-form-item layui-form-text">
            <div style="">
                <label class="layui-form-label">发送给:${toId}</label>
                <div class="layui-input-block">
                    <textarea placeholder="请输入内容" id="send_context" class="layui-textarea"></textarea>
                </div>
            </div>
        </div>

        <button type="button" id="send_btn" style="width:30%;margin-left: 70%"
                class="layui-btn layui-btn-lg layui-btn-primary layui-btn-radius">发送
        </button>

    </form>
</div>

</body>
</html>

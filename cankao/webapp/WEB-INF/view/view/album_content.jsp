<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>${albumInfo.name}|${albumInfo.category}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/layui/css/layui.css" type="text/css" charset="UTF-8"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/st-style.css" type="text/css" charset="UTF-8"/>
    <script src="https://libs.baidu.com/jquery/2.1.4/jquery.min.js" charset="UTF-8"></script>
    <script src="${pageContext.request.contextPath}/static/layui/layui.all.js" charset="UTF-8"></script>
    <script type="text/javascript">
        $(function(){
            $("#icon_praise").click(function () {
                $.ajax({
                    url: "http://localhost:8080/addPraise",
                    type: "post",
                    data: {"albumId":'${albumInfo.id}'},
                    dataType: "json",
                    success: function (result) {
                        console.log(result.data);
                        if (result.status == 0) {
                            layer.msg("点赞成功!",{offset:250});
                            var praise = parseInt($("#praise_count").html());
                            $("#praise_count").html(praise + 1);
                            console.log(praise);
                        } else {
                            layer.msg("点赞失败!",{offset:250});
                        }
                    },
                    error: function () {
                        alert("点赞异常");
                    }
                });
            });

            $("#COMMENT").click(function () {
                var commentText = $("#CommentText").val();
                var aId = "${albumInfo.id}";
                if(commentText==="" ) {
                    layer.open({
                        title: '评论提示',
                        content: '请填写评论内容',
                        shade: 0.5,
                        yes: function () {
                            layer.closeAll();
                        }
                    });
                }
                else{
                    $.ajax({
                        url: "http://localhost:8080/addComment",
                        type: "post",
                        data: {"TEXT": commentText,"AID":aId},
                        dataType: "json",
                        success: function (result) {
                            console.log(result.data);
                            if (result.status == 0) {
                                window.location.reload();
                            } else {
                                layer.open({
                                    title: '评论失败',
                                    content: '请登录',
                                    shade: 0.5,
                                    yes: function(){
                                        window.location.href = "http://localhost:8080/";
                                    }
                                });

                            }
                        },
                        error: function () {
                            alert("评论异常");
                        }
                    });
                }
            });

            $("#COMMENT1").click(function () {
                window.location.href = "http://localhost:8080/";
            });

            $("#GUANZHU").click(function () {
                var toId = "${albumInfo.userId}"
                $.ajax({
                    url: "http://localhost:8080/addfow",
                    type: "post",
                    data: {"TID":toId},
                    dataType: "json",
                    success: function (result) {
                        console.log(result.data);
                        if (result.status == 0) {
                            window.location.reload();
                        } else {
                            layer.open({
                                offset:'250px',
                                title: '关注失败 请登录！',
                                content: '关注失败',
                                shade: 0.5,
                                yes: function(){
                                    window.location.href = "http://localhost:8080/";
                                }
                            });

                        }
                    },
                    error: function () {
                        alert("关注异常");
                    }
                });
            });

            $("#QUGUAN").click(function () {
                var toId = "${albumInfo.userId}"
                layer.confirm('确定取消关注吗?', {icon: 3, title:'提示',offset:'250px'}, function(index){
                    $.ajax({
                        url: "http://localhost:8080/delfow",
                        type: "post",
                        data: {"TID":toId},
                        dataType: "json",
                        success: function (result) {
                            console.log(result.status);
                            console.log(result.data);
                            //如果删除成功
                            if (result.status == 0) {
                                layer.msg('取消关注成功!', {icon: 6,offset:250});
                                window.location.reload();
                            } else {
                                window.location.reload();
                            }
                        },
                        error: function () {
                            alert("取消关注发生异常");
                        }
                    });
                    layer.close(index);
                });
            });

        });

        function clickDel(e) {
            var commentId = $(e).attr("data-id");
            var userName = $(e).attr("data-name");

            layer.confirm('确定删除该评论吗?', {icon: 3, title:'提示',offset:'250px'}, function(index){
                $.ajax({
                    url: "http://localhost:8080/delcomment",
                    type: "post",
                    data: {"CID": commentId,"UID":userName},
                    dataType: "json",
                    success: function (result) {
                        //如果删除成功
                        if (result.status == 0) {
                            layer.msg('删除成功!', {icon: 6});
                            window.location.reload();
                        } else {
                            window.location.reload();
                        }
                    },
                    error: function () {
                        alert("删除相册发生异常");
                    }
                });
                layer.close(index);
            });
        }
    </script>


<%--    点击图片放大--%>
    <script>
        $(function () {
            $('#lookPhoto img').on('click', function () {
                layer.photos({
                    photos: '#lookPhoto',
                    shadeClose: true,
                    closeBtn: 2,
                    anim: 0
                });
            })
        });
    </script>

</head>
<body>
<jsp:include page="header.jsp"></jsp:include>
<div class="st-banner-ad-box">
    <div class="st-banner-ad theme-bg"></div>
</div>

<div class="album-box horizentol border-bottom border-top">
    <div class="album-info-box vertical">
        <div style="font-size: 33px">${albumInfo.name}</div>
        <div class="gray-color" style="font-size: 16px;margin-top: 10px">上传时间:${albumInfo.createTime}</div>
        <div class="gray-color" style="font-size: 18px;margin-top: 10px">${albumInfo.name}</div>

    </div>
    <div class="album-author-box horizentol border-left">
        <div class="album-info-avatar">
            <a href="/user?id=${albumInfo.userId}"><img src="/getAvatar?id=${albumInfo.userId}"></a>
        </div>
        <div class="vertical" style="margin-left: 10px">
            <div style="font-size: 16px">上传者：${albumInfo.userId}</div>
            <div>
                <c:if test="${sessionScope.myInfo.id != albumInfo.userId}">
                    <div style="margin-top:10px">
                        <c:if test="${empty sessionScope.myInfo}">
                            <a href="/index">
                            <button id = "GUANZHU1" type="button" class="layui-btn">登录后关注</button>
                        </c:if>
                                <c:if test="${not empty sessionScope.myInfo}">
                                    <c:if test="${isFollow == 1}">
                                    <button id = "QUGUAN" type="button" class="layui-btn layui-btn-primary">取消关注</button>
                                    </c:if>
                                    <c:if test="${isFollow == 0}">
                                    <button id = "GUANZHU" type="button" class="layui-btn">关注</button>
                                    </c:if>
                                </c:if>


                        <a href="/sendMessage?id=${albumInfo.userId}">
                        <button type="button" class="layui-btn">私信</button>
                        </a>
                    </div>
                </c:if>
            </div>
        </div>
    </div>
</div>

<%--展示照片--%>
<div style="margin-top: 20px" id="lookPhoto">
    <c:forEach var="photo" items="${photoList}">
        <div class="album-photo vertical" >
            <img src="/getImage?url=${photo.url}"/>
            <div class="gray-color">${photo.name}</div>
        </div>
    </c:forEach>
</div>


<%--点赞按钮--%>
<div style="width: 100%">
    <div class="horizentol" style="margin-left: 45%;">
        <div id = "icon_praise">
            <i class="layui-icon layui-icon-praise"  style="margin-right:10px;font-size: 40px; color: #009688;"></i>
        </div>

        <div id="praise_count" style="color: #bbbbbb;font-size:35px">${albumInfo.praiseCount}</div>
    </div>

</div>


<div class="comment_list">
    <hr>
    <c:if test="${empty sessionScope.myInfo}">
    <div id="addComment_WithoutId" class="ADDCOM_withoutId">
        <div class="ADDBottom_withoutId">
            <button id="COMMENT1" type="button" class="WithoutID  layui-btn layui-btn-lg layui-btn-radius layui-btn-primary">登录后评论</button>
        </div>
    </div>
    </c:if>
    <c:if test="${not empty sessionScope.myInfo}">
    <div id="addComment" class="ADDCOM">
        <textarea  id = "CommentText" name="" required lay-verify="required" placeholder="说点什么吧" class="layui-textarea"></textarea>
        <div class="ADDBottom">
            <button id="COMMENT" type="button" class="layui-btn layui-btn-lg layui-btn-radius">发表评论 </button>
        </div>

    </div>

    </c:if>


    <h3 style="text-indent:1em;font-size:25px;">评论列表</h3>
    <c:forEach var="Info" items="${commentInfo}">
    <div class="comment">
        <div class="imgdiv">
            <img class="imgcss" src="/getAvatar?id=${Info.userId}"/>
        </div>
        <div class="conmment_details">
            <div style="float:left;">
                <span class="comment_name">${Info.userId} </span>
                <span>${Info.createTime}</span>
            </div>

            <c:if  test="${Info.userId ==sessionScope.myInfo.id}">
                <div class="del" id="delCom" onclick = "clickDel(this)" data-id = '${Info.id}' data-name = '${Info.userId}'>
                    <a class="del_comment" data-id="1"> <i id = "del" class="icon layui-icon button-font" > 删除</i> </a>
                </div>
            </c:if>

            <div class="comment_content" > 
                    ${Info.context}
            </div>
        </div>
    </div>
    <hr>
    </c:forEach>
    <c:if test="${commentInfo.size()==0}">
        <div style="color: #bbbbbb;margin-left: 25px;margin-top:25px">暂时还没有评论哦!</div>
    </c:if>

    <div class="comment_add_or_last" >

    </div>

</body>
</html>

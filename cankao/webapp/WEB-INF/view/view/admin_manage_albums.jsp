<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>${myInfo.name} -相册管理</title>
    <meta charset="UTF-8">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/layui/css/layui.css" type="text/css"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/st-style.css" type="text/css"/>
    <script src="https://libs.baidu.com/jquery/2.1.4/jquery.min.js"></script>
    <script src="${pageContext.request.contextPath}/static/layui/layui.all.js"></script>
    <script src="${pageContext.request.contextPath}/static/layui/layui.js" charset="utf-8"></script>

</head>
<body class="bg-gray">
<jsp:include page="header.jsp"></jsp:include>
<div class="st-main horizentol" style="margin-top: 15px">
    <jsp:include page="my_left_bar.jsp"></jsp:include>
    <div class = "personal-content">
        <table class="layui-hide" id="test" lay-filter="album_table"></table>
    </div>

    <script type="text/html" id="checkboxTpl">
        {{# if(d.albumState == 'banned') {}}
        <button type="button" class="layui-btn layui-btn-danger layui-btn-xs ">封禁</button>
        {{# }else{ }}
        <button type="button" class="layui-btn layui-btn-primary layui-btn-xs">正常</button>
        {{# } }}
    </script>

    <script type="text/html" id="barDemo">
        {{# if(d.albumState == 'banned') {}}
        <a class="layui-btn layui-btn-xs" lay-event="deban">解封</a>
        {{# }else{ }}
        <a class="layui-btn layui-btn-xs" lay-event="ban">封禁</a>
        {{# } }}
        <a class="layui-btn layui-btn-xs" lay-event="edit">编辑</a>
        <a class="layui-btn layui-btn-danger layui-btn-xs" lay-event="del">删除</a>
    </script>

    <script>
        layui.use('table', function(){
            var table = layui.table;

            table.render({
                elem: '#test'
                ,url:'http://localhost:8080/admin/getAlbumList'
                ,cols: [[
                    {field:'id',  title: '相册ID', sort: true}
                    ,{field:'userId',  title: '所有者ID', sort: true}
                    ,{field:'name',  title: '相册名',sort:true}
                    ,{field:'category',  title: '分类',sort:true}
                    ,{field:'descp',  title: '相册描述'}
                    ,{field:'praiseCount',  title: '点赞', width:80, sort: true}
                    ,{field: 'url', title: '封面',
                        templet: function(d){
                            var url = '/getImage?url=' + d.coverId;
                            return '<div><img  src= "'+url+'" alt="" width="50px" height="50px"></a></div>';
                        },width:80,event :'preview'
                    }
                    ,{field:'createTime',  title: '创建日期', sort: true}
                    ,{field:'albumState',  title: '状态', width:110, sort: true, templet: '#checkboxTpl', unresize: true}
                    ,{fixed: 'right', width:178, align:'center', toolbar: '#barDemo'}
                ]]
                ,page: true
                ,parseData: function(res){ //res 即为原始返回的数据
                    return {
                        "code": res.status, //解析接口状态
                        "msg": res.msg, //解析提示文本
                        "count": res.data.length, //解析数据长度
                        "data": res.data //解析数据列表
                    };
                }
            });
            table.on('tool(album_table)',function (obj) {
                var albumName = obj.data.name;
                var albumId = obj.data.id;
                if(obj.event === 'edit'){
                    var url = '/editAlbum?albumId=' + obj.data.id;
                    window.open(url,"_blank");
                }
                else if(obj.event === 'del'){
                    layer.confirm('确定删除该相册「' + albumName +'」吗?该相册下的照片也会一并删除。', {icon: 3, title:'提示'}, function(index){
                        $.ajax({
                            url: "http://localhost:8080/delAlbum",
                            type: "post",
                            data: {"albumId": albumId},
                            dataType: "json",
                            success: function (result) {
                                //如果删除成功
                                if (result.status == 0) {
                                    layer.msg('删除成功!', {icon: 6,offset:250});
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
                else if (obj.event === 'preview'){
                    var url = "/getImage?url=" + obj.data.coverId;
                    var width = 800;
                    var height = 800;
                    // 创建对象
                    var img = new Image();
                    // 改变图片的src
                    img.src = url;
                    // 判断是否有缓存
                    if(img.complete){
                        // 打印
                        width = img.width>width?width:img.width;
                        height = img.height>height?height:img.height + 42;
                    }else{
                        // 加载完成执行
                        img.onload = function(){
                            width = img.width>width?width:img.width;
                            height = img.height>height?height:img.height + 42;
                        }
                    }
                    width = width + 'px';
                    height = height + 'px';
                    //页面层
                    layer.open({
                        title:'封面预览',
                        type: 1,
                        skin: 'layui-layer-rim', //加上边框
                        area: [width, height], //宽高
                        shadeClose: true, //开启遮罩关闭
                        end: function (index, layero) {
                            return false;
                        },
                        content: '<div style="text-align:center"><img src="'+url+'" /></div>'
                    });
                }
                else if(obj.event === 'ban'){
                    layer.prompt({
                        formType:2,
                        title:'请填写封禁原因（必填）',
                        area:['500px','150px'],
                        btnAlign:'c',
                        offset:'auto'
                    },function(value,index,elem){
                        var note = value;
                        $.ajax({
                            url: "http://localhost:8080/admin/banAlbum",
                            type: "post",
                            data: {"albumId": albumId,"note": note},
                            dataType: "json",
                            offset:'auto',
                            success: function (result) {
                                //如果删除成功
                                if (result.status == 0) {
                                    layer.msg('封禁成功!', {icon: 6,offset:250});
                                    window.location.reload();
                                } else {
                                    window.location.reload();
                                }
                            },
                            error: function () {
                                alert("封禁发生异常");
                            }
                        });
                        layer.close(index);
                    });
                }
                else if (obj.event === 'deban'){
                    layer.confirm('确定解禁该相册「' + albumName +'」吗?。', {icon: 3, title:'提示'}, function(index){
                        $.ajax({
                            url: "http://localhost:8080/admin/debanAlbum",
                            type: "post",
                            data: {"albumId": albumId},
                            dataType: "json",
                            offset:'auto',
                            success: function (result) {
                                //如果删除成功
                                if (result.status == 0) {
                                    layer.msg('解禁成功!', {icon: 6,offset:250});
                                    window.location.reload();
                                } else {
                                    window.location.reload();
                                }
                            },
                            error: function () {
                                alert("解禁发生异常");
                            }
                        });
                        layer.close(index);
                    });
                }
            })
        });
    </script>
</body>
</html>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%--
  Created by IntelliJ IDEA.
  User: root
  Date: 28.06.15
  Time: 11:19
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title></title>
    <%--<link href="<%=request.getContextPath()%>/resources/css/bootstrap-theme.css" rel="stylesheet"/>--%>
    <%--<link href="<%=request.getContextPath()%>/resources/css/bootstrap-theme.css.map" rel="stylesheet"/>--%>
    <link href="<%=request.getContextPath()%>/resources/css/bootstrap.css" rel="stylesheet"/>
    <link href="<%=request.getContextPath()%>/resources/css/test.questions.css" rel="stylesheet"/>
</head>

<body>
<%@include file="template/header.jsp" %>
<link href="<%=request.getContextPath()%>/resources/css/header.css" rel="stylesheet"/>
<script src="http://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/js/toastr.js" ></script>
<link rel="stylesheet" href="http://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/css/toastr.css" />

<c:set var="testId" value="${test.testId}" scope="page"/>

<div style="margin: 0 auto; width: 700px; ">


    <div class="test_questions" id="question-test">
        <c:forEach items="${test.testsQuestions}" var="testsQuestion">
            <div>
                    <%--<div class="question_header choices active_choice selected"><c:out value="${testsQuestion.question.name}"/></div>--%>
                <div class="jumbotron">
                    <h3><a name="<c:out value='${testsQuestion.question.name}'/>" class="question_anchor"><c:out value="${testsQuestion.question.name}"/></a></h3>
                    <ul class="choices">
                        <c:forEach items="${testsQuestion.question.answers}" var="answer">
                            <c:set var="isCorrect"
                                   value="${(testsQuestion.correct and answer.content.equals(testsQuestion.selectedAnswer.content) ) or ((not testsQuestion.correct) and testsQuestion.pk.correctExist and answer.content.equals(testsQuestion.pk.newCorrectAnswer))}"/>

                            <i class="mdi-navigation-check"
                               style="position: absolute; margin-left: -20px; margin-top: 5px; display: ${isCorrect ? "" : "none"} "
                               title="Ця відповідь перевірена адміністратором." is-correct="${isCorrect}" exist-any-correct=""></i>

                            <li class="${answer.content.equals(testsQuestion.selectedAnswer.content) ? "active_choice selected" : "active_choice active"}" style="padding-bottom:  30px;">

                                <div class="lastUnit" style="position: absolute; width: 580px;"
                                     count="${answer.selectedCount}">
                                    <div style="display: none" class="question_name_">${testsQuestion.question.name}</div>
                                    <div class="answer_"><c:out value="${answer.content}"/></div>
                                    <%--<c:out value="${answer.content}"/>--%>
                                </div>
                                <div class="qq"></div>
                            </li>
                        </c:forEach>
                    </ul>
                </div>
            </div>
        </c:forEach>
    </div>
</div>
<div class="right">
    <div id="fixed">
        <div class="panel panel-default">
            <div class="panel-body">
                ${test.name} <br/>
                ${test.discipline}<br/>
                <c:if test="${not (empty test.group.trim() or test.course == 0)}">
                    ${test.group}-${test.course}<br/>
                </c:if>
                Submission time ${test.submissionTime}<br/>
                <c:if test="${test.testResult != null}">
                    ${test.testResult}<br/>
                </c:if>
                <sec:authorize access="hasRole('ROLE_ADMIN')">
                    ${test.userATutor.name}<br/>
                </sec:authorize>

            </div>
        </div>
        <div class="panel panel-default">
            <div class="panel-body">
                <div class="togglebutton">
                    Show statistic
                    <label style="float: right">
                        <input type="checkbox" id="show-statistic"><span class="toggle"></span>
                    </label>
                </div>
            </div>
        </div>
        <div class="panel panel-default">
            <div class="panel-body">
                Якщо ви хочете запропонувати свій варіант відповіді, просто натисніть на відповідь і після підтвердження адміністратором вона вважатиметься правильною.
            </div>
        </div>
    </div>
</div>

<script>

    toastr.options = {
        "closeButton": false,
        "debug": true,
        "newestOnTop": false,
        "progressBar": false,
        "positionClass": "toast-top-center",
        "preventDuplicates": false,
        "onclick": null,
        "showDuration": "300",
        "hideDuration": "1000",
        "timeOut": "2000",
        "extendedTimeOut": "1000",
        "showEasing": "swing",
        "hideEasing": "linear",
        "showMethod": "fadeIn",
        "hideMethod": "fadeOut"
    };

    function replaceStr(str){
        return str.replace(" ", "_");
    }

    $(".question_anchor").each(function(){
       $(this).attr("name", $(this).attr("name").replace(" ", "_"));
    });

    function sturtup(){
        $(".choices").each(function(){
            var hasAnyCorrect = false;
            $(this).find(".mdi-navigation-check").each(function(){
                    if($(this).attr("is-correct") === "true")    {
                        hasAnyCorrect = true;
                    }
            })

            $(this).find(".mdi-navigation-check").each(function(){
                console.log("Cor: " + $(this).attr("is-correct") );
                if($(this).attr("is-correct") === "false" && $(this).next().hasClass("selected") && hasAnyCorrect) {
                    $(this).next().addClass("wrong_answer");
                    $(this).next().find(".qq").addClass("hide");
                } else if(hasAnyCorrect && $(this).attr("is-correct") === "true") {
                    $(this).next().addClass("btn-material-green-500");
                }
            })
        })
    }

    sturtup();
    $(".lastUnit").click(function () {
        console.log("Questionin div: " +  $(this).find(".answer_").html().trim() ) ;
        var question = $(this).find(".question_name_").html().trim();
        var answer = $(this).find(".answer_").html().trim();
        var obj = {question: question, testId: "${testId}", answer: answer};
        console.log("Send object: " + JSON.stringify(obj));
        var parent = $(this).parent().parent();

        $.post("<c:url value='/correct-answer'/>", obj).done(function (data) {
            var responseObj = JSON.parse(data);
            if(responseObj.status !== 0) {
                alert("Error");
            } else {
                if(responseObj.action === "proposed") {
                    toastr["success"]("Ваш варіант прийнято на обробку!")
                }else {
                    $(parent).find(".mdi-navigation-check").each(function () {
                        if ($(this).next().hasClass("selected") && $(this).next().text().trim() !== answer) {
                            $(this).next().addClass("wrong_answer");
                            $(this).next().find(".qq").addClass("hide");
                        }

                        if ($(this).next().find(".answer_").text().trim() === answer) {
                            $(this).css("display", "");
                            if ($(this).next().hasClass("selected")){
                                $(this).next().removeClass("wrong_answer");
                                $(this).next().find(".qq").removeClass("hide");
                            }
                        } else {
                            $(this).css("display", "none");
                        }
                    })

                    toastr["success"]("Ваш варіант прийнято! Оновлення відбулося!")
                }

            }

        }).fail(function () {
            console.log("error");
        })
    });

    $("#show-statistic").click(function () {
        window.setTimeout(function(){
            if ($("input[id='show-statistic']:checked").length >= 1) {

                buildStatistic();
            } else {
                cleanStatistic();
            }
        },100)

    });

    function cleanStatistic() {
        var divs = $("#question-test > div");
        divs.each(function () {
            var count = 0;

            $(this).find(".lastUnit").each(function () {
                count += parseInt($(this).attr("count"))
            });

            $(this).find(".active_choice").each(function () {
                var ddd = this;
                $(this).removeClass("");
                var isSelected = $(this).hasClass("selected");
                $(ddd).find(".qq").each(function () {

                    if (isSelected) {
                        var interest = (parseInt($(ddd).find(".lastUnit").attr("count")) * 100) / count;
                        var current = 100 - interest;
                        $(this).animate({"width": "+=" + ((current * $(ddd).outerWidth()) / 100 ) + "px"}, 1000);
                    } else {
                        var l = (parseInt($(ddd).find(".lastUnit").attr("count")) * 100) / count;
                        $(this).animate({"width": "-=" + ((l * $(ddd).outerWidth()) / 100 ) + "px"}, 1000);
                    }
                });
            });

        })

        sturtup();
    }

    function buildStatistic() {
        var divs = $("#question-test > div");
        divs.each(function () {
            var count = 0;

            $(this).find(".lastUnit").each(function () {
                count += parseInt($(this).attr("count"))
            });

            $(this).find(".active_choice").each(function () {
                var ddd = this;
                var isSelected = $(this).hasClass("selected");
                $(this).removeClass("wrong_answer");
                $(ddd).find(".qq").each(function () {
                    $(this).removeClass("hide");

                    if (isSelected) {
                        var interest = (parseInt($(ddd).find(".lastUnit").attr("count")) * 100) / count;
                        var current = 100 - interest;
                        $(this).animate({"width": "-=" + ((current * $(ddd).outerWidth() + 16) / 100 ) + "px"}, 1000);
                    } else {
                        var interest2 = (parseInt($(ddd).find(".lastUnit").attr("count")) * 100) / count;
                        $(this).css("width", "0px");
                        $(this).animate({"width": "+=" + ((interest2 * $(ddd).outerWidth() + 16) / 100 ) + "px"}, 1000);
                        $(this).addClass("bnt btn-material-green-500");
                    }


                });
            });

        })
    }

    function setNormalHeight() {
        var divs = $("#question-test > div");
        divs.each(function () {

            $(this).find(".active_choice").each(function () {
                var ddd = this;
                var height = $(ddd).find(".lastUnit").outerHeight();
                var isSelected = $(this).hasClass("selected");
                $(ddd).find(".qq").each(function () {
                    $(ddd).css("height", (height + 15 + 7) + "px");
                    if (isSelected) {
                        $(this).css("width", $(ddd).outerWidth() + "px");
                        $(this).addClass("bnt btn-material-green-500");
                    }
                    $(this).css({"height": ((height + 15  + 7) + "px")});
                });
            });
        });
    }

    setNormalHeight();

    $(function () {
        var offset = $("#fixed").offset();
        var topPadding = 15;
        $(window).scroll(function () {
            if ($(window).scrollTop() > offset.top) {
                $("#fixed").stop().animate({marginTop: $(window).scrollTop() - offset.top + topPadding});
            }
            else {
                $("#fixed").stop().animate({marginTop: 0});
            }

        });
    });
</script>
<style>
    .right {
        margin-top: 2px;
        float: left;
        width: 20%;
    }

    #fixed {
        /*background: #CCC;*/
        padding: 20px;
    }

    .hide {
        display: none;
    }

    a {
        text-decoration: none;
    }

</style>
</body>
</html>
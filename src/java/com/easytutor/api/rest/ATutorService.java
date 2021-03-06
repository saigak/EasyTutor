package com.easytutor.api.rest;

import com.easytutor.api.rest.obj.*;
import com.easytutor.dao.*;
import com.easytutor.models.*;
import com.easytutor.utils.ApplicationContextProvider;
import com.easytutor.utils.TemporaryTestStorage;

import java.util.*;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

/**
 * Created by root on 12.06.15.
 */
@Path("/atutor")
public class ATutorService {

    private TemporaryTestStorage tempTestIds = (TemporaryTestStorage) ApplicationContextProvider.getApplicationContext().getBean("temporaryTestStorage");

    private TestDAO testDAO = ApplicationContextProvider.getApplicationContext().getBean(TestDAO.class);
    private QuestionDAO questionDAO = ApplicationContextProvider.getApplicationContext().getBean(QuestionDAO.class);
    private AnswerDAO answerDAO = ApplicationContextProvider.getApplicationContext().getBean(AnswerDAO.class);
    private UserATutorDAO userATutorDAO = ApplicationContextProvider.getApplicationContext().getBean(UserATutorDAO.class);
    private TestResultDAO testResultDAO = ApplicationContextProvider.getApplicationContext().getBean(TestResultDAO.class);

    private String checkNumberQuestionInTestName = ".+\\(.+[0-9]{1,1000}/[0-9]{1,1000}\\)";


    @POST
    @Path("test/questions")
    @Produces(MediaType.APPLICATION_JSON)
    public Response storeObjects(TestInfo testInfo) {

        Runnable task2 = () -> {


            UUID testId = UUID.fromString(testInfo.getTestId());
            Test test = new Test();
            test.setSubmissionTime(new Date());


            Pattern p = Pattern.compile(checkNumberQuestionInTestName);
            Matcher m = p.matcher(testInfo.getModuleName().trim());
            if (m.matches())
                test.setName(testInfo.getModuleName().substring(0, testInfo.getModuleName().indexOf("(")).trim());
            else
                test.setName(testInfo.getModuleName().trim());
            test.setTestId(testId);
            test.setDiscipline(testInfo.getDiscipline().trim());
            test.setGroup(extractGroup(testInfo.getGroup()).trim());
            test.setCourse(getCourse(testInfo.getGroup()));

            List<QuestionInfo> questions = testInfo.getBody();

            UserATutor userATutor = new UserATutor();
            userATutor.setName(testInfo.getUser().trim());
            userATutorDAO.saveOrUpdate(userATutor);

            List<TestsQuestions> testsQuestions = new ArrayList<>();


            List<Answer> currentAnswers = new ArrayList<>();

            for (QuestionInfo question : questions.stream().distinct().collect(Collectors.toList())) {
                Question questionObj = new Question(question.getQuestion().trim(), question.getQuestionHeader());
                Answer selectedAnswer = new Answer(question.getAnswer().trim());
                selectedAnswer.setId(UUID.randomUUID());
                List<String> answers = question.getAnswers();

                questionDAO.saveOrUpdate(questionObj);
                TestsQuestions testsQuestions1 = null;

                if(currentAnswers.contains(selectedAnswer)) {

                    for (Answer currentAnswer : currentAnswers) {
                        if (currentAnswer.getContent().equals(selectedAnswer.getContent())) {
                            testsQuestions1 = createTestQuestions(test, questionObj, currentAnswer);
                            break;
                        }
                    }

                } else {
                    answerDAO.storeAnswer(selectedAnswer);
                    currentAnswers.add(selectedAnswer);
                    testsQuestions1 = createTestQuestions(test, questionObj, selectedAnswer);

                }



                List<QuestionsAnswers> answersList = new ArrayList<>();

                for (String answer : answers.stream().distinct().map(String::trim).collect(Collectors.toList())) {
                    Answer answerObj = new Answer(answer);
                    answerObj.setId(UUID.randomUUID());

                    if(currentAnswers.contains(answerObj)) {

                        for (Answer currentAnswer : currentAnswers) {
                            if (currentAnswer.getContent().equals(answerObj.getContent())) {
                                answersList.add(createQuestionsAnswers(questionObj, currentAnswer, testId));
                            }
                        }

                    } else {
                        answerDAO.storeAnswer(answerObj);
                        currentAnswers.add(answerObj);
                        answersList.add(createQuestionsAnswers(questionObj, answerObj, testId));
                    }

                }

                questionObj.setQuestionsAnswers(answersList);
                questionDAO.saveOrUpdate(questionObj);


                testsQuestions.add(testsQuestions1);
                questionObj.getTestsQuestions().add(testsQuestions1);

            }
            test.setUserATutor(userATutor);
            test.setTestsQuestions(testsQuestions);

            testDAO.saveOrUpdate(test);

        };

        new Thread(task2).start();


        return Response.ok().build();
    }


    public QuestionsAnswers createQuestionsAnswers(Question question, Answer answer, UUID testId) {
        QuestionsAnswers questionsAnswers = new QuestionsAnswers();
        questionsAnswers.setQuestion(question);
        questionsAnswers.setTestId(testId);
        questionsAnswers.setAnswer(answer);
        return questionsAnswers;
    }

    public TestsQuestions createTestQuestions(Test test, Question question, Answer answer) {
        TestsQuestions testsQuestions = new TestsQuestions();
        testsQuestions.setTest(test);
        testsQuestions.setQuestion(question);
        testsQuestions.setSelectedAnswer(answer);
        return testsQuestions;
    }

    @POST
    @Path("test/scores")
    @Produces(MediaType.APPLICATION_JSON)
    public void storeTestResult(TestScores testScores) {
        TestResult testResult = new TestResult();

        testResult.setTestId(UUID.fromString(testScores.getId()));
        testResult.setMax(testScores.getMaxScores());
        testResult.setCurrent(testScores.getScores());
        testResultDAO.storeTestResult(testResult);
        Logger.getLogger(ATutorService.class.getName()).info("Test scores: " + testScores);
    }

    @GET
    @Path("test/temp-test")
    public Response generateTempTestId() {
        UUID testId = UUID.randomUUID();
        System.out.println("Generated test id: " + testId);
//        tempTestIds.putTestId(testId);
        return Response.ok(testId.toString()).build();
    }

    @POST
    @Path("answer-for-question")
    @Produces(MediaType.APPLICATION_JSON)
    public List<FoundAnswer> getAnswerForQuestion(LookingAnswer question) {
//    curl -XPOST http://localhost:8080/easytutor/rest/atutor/answer-for-question -d '{"testName" : "Модуль 1", "questionName":"Beб-caйт – цe", "discipline": "Програмування інтернет", "group": "СП-31"}' -H "Content-Type:application/json"


        try {
            Pattern p = Pattern.compile(checkNumberQuestionInTestName);
            Matcher m = p.matcher(question.getTestName().trim());
            String newTestName;
            if (m.matches())
                newTestName = question.getTestName().substring(0, question.getTestName().indexOf("("));
            else
                newTestName = question.getTestName();

            return answerDAO.getAnswersByInfo(
                    newTestName,
                    question.getDiscipline(),
                    extractCourseOpt(question.getGroup()),
                    extractGroupOpt(question.getGroup()),
                    question.getQuestions());

        } catch (Exception e) {
            System.out.println("Return ");
            return new ArrayList<>();
        }


    }


    @OPTIONS
    @Path("/")
    public Response getOptions() {
        return Response.ok()
                .header("Access-Control-Allow-Origin", "*")
                .header("Access-Control-Allow-Headers", "Accept, Content-type, X-Json, X-Prototype-Version, X-Requested-With")
                .build();
    }

    public int getCourse(String str) {
        try {
            String strNumber = str.split("-")[1];
            return Integer.valueOf(strNumber.charAt(0) + "");
        } catch (Exception e) {
            return 0;
        }
    }

    public String extractGroup(String string) {
        try {
            return string.split("-")[0];
        } catch (Exception e) {
            return "";
        }
    }

    public Optional<Integer> extractCourseOpt(String str) {
        try {
            String strNumber = str.split("-")[1];
            return Optional.of(Integer.valueOf(strNumber.charAt(0) + ""));
        } catch (Exception e) {
            return Optional.empty();
        }
    }

    public Optional<String> extractGroupOpt(String string) {
        try {
            if (string.split("-")[0].trim().isEmpty())
                return Optional.empty();
            else
                return Optional.of(string.split("-")[0]);
        } catch (Exception e) {
            return Optional.empty();
        }
    }
}

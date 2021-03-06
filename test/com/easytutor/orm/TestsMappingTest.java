package com.easytutor.orm;

import com.easytutor.models.*;
import com.easytutor.utils.ApplicationContextProvider;
import com.easytutor.utils.HibernateUtil;
import org.hibernate.Session;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;
//import

/**
 * Created by root on 22.06.15.
 */
public class TestsMappingTest {

    Session session = HibernateUtil.getSessionFactory().openSession();

    @Before
    public void beforeAll() throws IOException {

        String text = new String(Files.readAllBytes(Paths.get("db/scheme.sql")), StandardCharsets.UTF_8);
        String queries[] = text.split(";");
        for (String query : queries) {
            if (!query.trim().isEmpty())
                session.createSQLQuery(query.replace("\n", "")).executeUpdate();
        }
    }

    @Test
    public void storeTestQuestionSelectedAnswerTest() {

        session.beginTransaction();

        com.easytutor.models.Test test = new com.easytutor.models.Test();

        UUID testId = UUID.randomUUID();
        test.setName("test name");
        test.setTestId(testId);

        UserATutor userAtutor = new UserATutor();
        userAtutor.setName("Khrupalik");
        session.save(userAtutor);

        Question question = new Question();
        question.setName("Question1");

        Question questionNext = new Question();
        questionNext.setName("Question2");
//        session.save(question);
//        session.save(questionNext);


        Answer answer = new Answer();
        answer.setContent("answer");
        session.save(answer);

        Answer answerNext = new Answer();
        answerNext.setContent("answer next");
        session.save(answerNext);

        QuestionsAnswers questionsAnswers = createQuestionsAnswers(question, answer, testId);
        QuestionsAnswers questionsAnswers1 = createQuestionsAnswers(questionNext, answerNext, testId);

        question.getQuestionsAnswers().add(questionsAnswers);
        questionNext.getQuestionsAnswers().add(questionsAnswers1);

        answer.getQuestionsAnswers().add(questionsAnswers);
        answerNext.getQuestionsAnswers().add(questionsAnswers1);

        session.save(question);
        session.save(questionNext);

//        session.getTransaction().commit();

        TestsQuestions testsQuestions = createTestQuestions(test, question, userAtutor, answer);
        TestsQuestions testsQuestionsNext = createTestQuestions(test, questionNext, userAtutor, answerNext);

        test.getTestsQuestions().add(testsQuestions);
        test.getTestsQuestions().add(testsQuestionsNext);

        question.getTestsQuestions().add(testsQuestions);
        question.getTestsQuestions().add(testsQuestionsNext);

        session.save(test);

        UserATutor userATutorFromDB = (UserATutor) session.get(UserATutor.class, userAtutor.getName());

        assertEquals("ATutor user name not equals!", userATutorFromDB.getName(), userAtutor.getName());

        com.easytutor.models.Test testFromDB = (com.easytutor.models.Test) session.get(com.easytutor.models.Test.class, test.getTestId());

        assertEquals("Test name not equals!", test.getName(), testFromDB.getName());

        assertEquals("Size question in test not equals!", 2, testFromDB.getTestsQuestions().size());

//        testFromDB.getTestsQuestions().forEach(
//                e -> assertEquals("User in test not equals!", userAtutor, e.getUserATutor())
//        );

        assertEquals("Selected answer not equals!", testFromDB.getTestsQuestions().get(0).getSelectedAnswer(), answer);

        assertEquals("Selected answer not equals!", testFromDB.getTestsQuestions().get(1).getSelectedAnswer(), answerNext);

        testFromDB.getTestsQuestions().forEach(
                e -> System.out.println("Selected answer " + e.getSelectedAnswer() + " for question " + e.getQuestion())
        );

        session.getTransaction().commit();

    }

//    @Test
    public void getAllTests() {
        List<com.easytutor.models.Test> tests = session.createQuery("from Test").list();
        tests.forEach( test -> {

            System.out.println("Test name: " + test.getName() + " " + test.getTestsQuestions().size());
            test.getTestsQuestions().forEach(
                    question -> {
                        System.out.println("    Question: " + question.getQuestion().getName());
                        System.out.println("    Selected answer: " + question.getSelectedAnswer().getContent());
                    }
            );
        });

    }

    public TestsQuestions createTestQuestions(com.easytutor.models.Test test, Question question, UserATutor userAtutor, Answer answer) {
        TestsQuestions testsQuestions = new TestsQuestions();
        testsQuestions.setTest(test);
        testsQuestions.setQuestion(question);
        testsQuestions.setSelectedAnswer(answer);
        return testsQuestions;
    }

    public QuestionsAnswers createQuestionsAnswers(Question question, Answer answer, UUID testId) {
        QuestionsAnswers questionsAnswers = new QuestionsAnswers();
        questionsAnswers.setQuestion(question);
        questionsAnswers.setTestId(testId);
        questionsAnswers.setAnswer(answer);
        return questionsAnswers;
    }
}

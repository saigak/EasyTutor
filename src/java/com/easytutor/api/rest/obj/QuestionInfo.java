package com.easytutor.api.rest.obj;

import java.io.Serializable;
import java.util.List;

/**
 * Created by root on 12.06.15.
 */
public class QuestionInfo implements Serializable {

    private String answer;
    private String scoreOnQuestion;
    private String questionHeader;
    private String question;
    private List<String> answers;

    public List<String> getAnswers() {
        return answers;
    }

    public void setAnswers(List<String> answers) {
        this.answers = answers;
    }

    public String getQuestion() {
        return question;
    }

    public void setQuestion(String question) {
        this.question = question;
    }

    public String getQuestionHeader() {
        return questionHeader;
    }

    public void setQuestionHeader(String questionHeader) {
        this.questionHeader = questionHeader;
    }

    public String getScoreOnQuestion() {
        return scoreOnQuestion;
    }

    public void setScoreOnQuestion(String scoreOnQuestion) {
        this.scoreOnQuestion = scoreOnQuestion;
    }


    public String getAnswer() {
        return answer;
    }

    public void setAnswer(String answer) {
        this.answer = answer;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        QuestionInfo that = (QuestionInfo) o;

        return !(question != null ? !question.equals(that.question) : that.question != null);

    }

    @Override
    public int hashCode() {
        return question != null ? question.hashCode() : 0;
    }

    @Override
    public String toString() {
        return "QuestionInfo{" +
                "answer='" + answer + '\'' +
                ", scoreOnQuestion='" + scoreOnQuestion + '\'' +
                ", questionHeader='" + questionHeader + '\'' +
                ", question='" + question + '\'' +
                ", answers=" + answers +
                '}';


    }
}

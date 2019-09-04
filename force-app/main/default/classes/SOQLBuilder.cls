/**
 * Created by AntonAntoniuk on 04.09.2019.
 */

public interface SOQLBuilder {

    void reset();
    void setSelect();
    void setFields();
    void setFrom();
    void setObject();
}
package model;

import java.math.BigDecimal;

public class ReturnDetail9 {
    private int id;
    private String conditionAtReturn;
    private BigDecimal damageFine;
    private BigDecimal lateFine;
    private LoanDetail9 loanDetail;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getConditionAtReturn() {
        return conditionAtReturn;
    }

    public void setConditionAtReturn(String conditionAtReturn) {
        this.conditionAtReturn = conditionAtReturn;
    }

    public BigDecimal getDamageFine() {
        return damageFine;
    }

    public void setDamageFine(BigDecimal damageFine) {
        this.damageFine = damageFine;
    }

    public BigDecimal getLateFine() {
        return lateFine;
    }

    public void setLateFine(BigDecimal lateFine) {
        this.lateFine = lateFine;
    }

    public LoanDetail9 getLoanDetail() {
        return loanDetail;
    }

    public void setLoanDetail(LoanDetail9 loanDetail) {
        this.loanDetail = loanDetail;
    }

    public BigDecimal tinhTienPhatDong() {
        return damageFine.add(lateFine);
    }

    public BigDecimal getLineFine() {
        return tinhTienPhatDong();
    }
}

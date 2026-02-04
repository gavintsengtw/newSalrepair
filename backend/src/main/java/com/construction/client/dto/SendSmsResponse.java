package com.construction.client.dto;

public class SendSmsResponse {
	private String msgid;	//簡訊序號
	private String dstaddr;	//受訊方手機號碼。
	private String dlvtime;	//簡訊預約時間。格式為YYYYMMDDHHMMSS。
	private String donetime;	//簡訊最新狀態時間。格式為YYYYMMDDHHMMSS。
	private String statuscode;	//0 或1 代表發送成功。發送時statuscode<0的簡訊為發送失敗，不會有狀態回報。
	private String statusstr;	//簡訊狀態說明。請參考附錄三的說明。
	private String statusFlag;	//簡訊狀態。請參考附錄一的說明。
    private String uid; // 資料流編號

	public String getMsgid() {
		return msgid;
	}
	public String getDstaddr() {
		return dstaddr;
	}
	public String getDlvtime() {
		return dlvtime;
	}
	public String getDonetime() {
		return donetime;
	}
	public String getStatuscode() {
		return statuscode;
	}
	public String getStatusstr() {
		return statusstr;
	}

	public void setMsgid(String msgid) {
		this.msgid = msgid;
	}
	public void setDstaddr(String dstaddr) {
		this.dstaddr = dstaddr;
	}
	public void setDlvtime(String dlvtime) {
		this.dlvtime = dlvtime;
	}
	public void setDonetime(String donetime) {
		this.donetime = donetime;
	}
	public void setStatuscode(String statuscode) {
		this.statuscode = statuscode;
	}
	public void setStatusstr(String statusstr) {
		this.statusstr = statusstr;
	}
	public String getStatusFlag() {
		return statusFlag;
	}
	public void setStatusFlag(String statusFlag) {
		this.statusFlag = statusFlag;
	}
    public String getUid() {
        return uid;
    }
    public void setUid(String uid) {
        this.uid = uid;
    }
}

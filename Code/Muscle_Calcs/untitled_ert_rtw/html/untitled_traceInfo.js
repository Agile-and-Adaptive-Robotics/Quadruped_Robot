function RTW_Sid2UrlHash() {
	this.urlHashMap = new Array();
	/* <Root>/Analog Input */
	this.urlHashMap["untitled:1"] = "msg=rtwMsg_notTraceable&block=untitled:1";
	/* <Root>/Constant */
	this.urlHashMap["untitled:13"] = "msg=rtwMsg_notTraceable&block=untitled:13";
	/* <Root>/Data Type Conversion */
	this.urlHashMap["untitled:9"] = "msg=rtwMsg_notTraceable&block=untitled:9";
	/* <Root>/Data Type Conversion1 */
	this.urlHashMap["untitled:11"] = "msg=rtwMsg_notTraceable&block=untitled:11";
	/* <Root>/Data Type Conversion3 */
	this.urlHashMap["untitled:20"] = "untitled.c:49,68&untitled.h:86";
	/* <Root>/Gain */
	this.urlHashMap["untitled:10"] = "msg=rtwMsg_notTraceable&block=untitled:10";
	/* <Root>/Gain1 */
	this.urlHashMap["untitled:19"] = "untitled.c:46&untitled.h:118&untitled_data.c:41";
	/* <Root>/Scope */
	this.urlHashMap["untitled:8"] = "untitled.h:93";
	/* <Root>/Scope1 */
	this.urlHashMap["untitled:21"] = "untitled.h:97";
	/* <Root>/Sine Wave */
	this.urlHashMap["untitled:16"] = "untitled.c:41&untitled.h:85,106,109,112,115&untitled_data.c:29,32,35,38";
	/* <S1>/Data Type Conversion */
	this.urlHashMap["untitled:14:114"] = "msg=rtwMsg_notTraceable&block=untitled:14:114";
	/* <S1>/PWM */
	this.urlHashMap["untitled:14:215"] = "msg=rtwMsg_notTraceable&block=untitled:14:215";
	/* <S2>/Data Type Conversion */
	this.urlHashMap["untitled:15:114"] = "msg=rtwMsg_notTraceable&block=untitled:15:114";
	/* <S2>/PWM */
	this.urlHashMap["untitled:15:215"] = "msg=rtwMsg_notTraceable&block=untitled:15:215";
	/* <S3>/Data Type Conversion */
	this.urlHashMap["untitled:17:114"] = "untitled.c:70,77";
	/* <S3>/PWM */
	this.urlHashMap["untitled:17:215"] = "untitled.c:76,198&untitled.h:103&untitled_data.c:26";
	this.getUrlHash = function(sid) { return this.urlHashMap[sid];}
}
RTW_Sid2UrlHash.instance = new RTW_Sid2UrlHash();
function RTW_rtwnameSIDMap() {
	this.rtwnameHashMap = new Array();
	this.sidHashMap = new Array();
	this.rtwnameHashMap["<Root>"] = {sid: "untitled"};
	this.sidHashMap["untitled"] = {rtwname: "<Root>"};
	this.rtwnameHashMap["<S1>"] = {sid: "untitled:14"};
	this.sidHashMap["untitled:14"] = {rtwname: "<S1>"};
	this.rtwnameHashMap["<S2>"] = {sid: "untitled:15"};
	this.sidHashMap["untitled:15"] = {rtwname: "<S2>"};
	this.rtwnameHashMap["<S3>"] = {sid: "untitled:17"};
	this.sidHashMap["untitled:17"] = {rtwname: "<S3>"};
	this.rtwnameHashMap["<Root>/Analog Input"] = {sid: "untitled:1"};
	this.sidHashMap["untitled:1"] = {rtwname: "<Root>/Analog Input"};
	this.rtwnameHashMap["<Root>/Constant"] = {sid: "untitled:13"};
	this.sidHashMap["untitled:13"] = {rtwname: "<Root>/Constant"};
	this.rtwnameHashMap["<Root>/Data Type Conversion"] = {sid: "untitled:9"};
	this.sidHashMap["untitled:9"] = {rtwname: "<Root>/Data Type Conversion"};
	this.rtwnameHashMap["<Root>/Data Type Conversion1"] = {sid: "untitled:11"};
	this.sidHashMap["untitled:11"] = {rtwname: "<Root>/Data Type Conversion1"};
	this.rtwnameHashMap["<Root>/Data Type Conversion3"] = {sid: "untitled:20"};
	this.sidHashMap["untitled:20"] = {rtwname: "<Root>/Data Type Conversion3"};
	this.rtwnameHashMap["<Root>/Gain"] = {sid: "untitled:10"};
	this.sidHashMap["untitled:10"] = {rtwname: "<Root>/Gain"};
	this.rtwnameHashMap["<Root>/Gain1"] = {sid: "untitled:19"};
	this.sidHashMap["untitled:19"] = {rtwname: "<Root>/Gain1"};
	this.rtwnameHashMap["<Root>/PWM"] = {sid: "untitled:14"};
	this.sidHashMap["untitled:14"] = {rtwname: "<Root>/PWM"};
	this.rtwnameHashMap["<Root>/PWM1"] = {sid: "untitled:15"};
	this.sidHashMap["untitled:15"] = {rtwname: "<Root>/PWM1"};
	this.rtwnameHashMap["<Root>/PWM2"] = {sid: "untitled:17"};
	this.sidHashMap["untitled:17"] = {rtwname: "<Root>/PWM2"};
	this.rtwnameHashMap["<Root>/Scope"] = {sid: "untitled:8"};
	this.sidHashMap["untitled:8"] = {rtwname: "<Root>/Scope"};
	this.rtwnameHashMap["<Root>/Scope1"] = {sid: "untitled:21"};
	this.sidHashMap["untitled:21"] = {rtwname: "<Root>/Scope1"};
	this.rtwnameHashMap["<Root>/Sine Wave"] = {sid: "untitled:16"};
	this.sidHashMap["untitled:16"] = {rtwname: "<Root>/Sine Wave"};
	this.rtwnameHashMap["<S1>/In1"] = {sid: "untitled:14:116"};
	this.sidHashMap["untitled:14:116"] = {rtwname: "<S1>/In1"};
	this.rtwnameHashMap["<S1>/Data Type Conversion"] = {sid: "untitled:14:114"};
	this.sidHashMap["untitled:14:114"] = {rtwname: "<S1>/Data Type Conversion"};
	this.rtwnameHashMap["<S1>/PWM"] = {sid: "untitled:14:215"};
	this.sidHashMap["untitled:14:215"] = {rtwname: "<S1>/PWM"};
	this.rtwnameHashMap["<S2>/In1"] = {sid: "untitled:15:116"};
	this.sidHashMap["untitled:15:116"] = {rtwname: "<S2>/In1"};
	this.rtwnameHashMap["<S2>/Data Type Conversion"] = {sid: "untitled:15:114"};
	this.sidHashMap["untitled:15:114"] = {rtwname: "<S2>/Data Type Conversion"};
	this.rtwnameHashMap["<S2>/PWM"] = {sid: "untitled:15:215"};
	this.sidHashMap["untitled:15:215"] = {rtwname: "<S2>/PWM"};
	this.rtwnameHashMap["<S3>/In1"] = {sid: "untitled:17:116"};
	this.sidHashMap["untitled:17:116"] = {rtwname: "<S3>/In1"};
	this.rtwnameHashMap["<S3>/Data Type Conversion"] = {sid: "untitled:17:114"};
	this.sidHashMap["untitled:17:114"] = {rtwname: "<S3>/Data Type Conversion"};
	this.rtwnameHashMap["<S3>/PWM"] = {sid: "untitled:17:215"};
	this.sidHashMap["untitled:17:215"] = {rtwname: "<S3>/PWM"};
	this.getSID = function(rtwname) { return this.rtwnameHashMap[rtwname];}
	this.getRtwname = function(sid) { return this.sidHashMap[sid];}
}
RTW_rtwnameSIDMap.instance = new RTW_rtwnameSIDMap();

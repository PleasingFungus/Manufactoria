//
// For correct measurement, DO NOT HOST THIS FROM ANOTHER SERVER
//
function _qcdst(){if(_qctzoff(0)!=_qctzoff(6))return 1;return 0;}
function _qctzoff(m){
var d1=new Date(2000,m,1,0,0,0,0);
var t=d1.toGMTString();
var d3=new Date(t.substring(0,t.lastIndexOf(" ")-1));
return d1-d3;
}
function _qceuc(s){
if(typeof(encodeURIComponent)=='function'){return encodeURIComponent(s);}
else{return escape(s);}
}
function _qcrnd(){return Math.round(Math.random()*2147483647);}
function _qcgc(n){
 var v='';
 var c=document.cookie;if(!c)return v;
 var i=c.indexOf(n+"=");
 var len=i+n.length+1;
 if(i>-1){
  var end=c.indexOf(";", len);
  if(end<0)end=c.length;
  v=c.substring(len,end);
 }
 return v;
}
function _qcdomain(){
 var d=document.domain;
 if(d.substring(0,4)=="www.")d=d.substring(4,d.length);
 var a=d.split(".");var len=a.length;
 if(len<3)return d;
 var e=a[len-1];
 if(e.length<3)return d;
 d=a[len-2]+"."+a[len-1];
 return d;
}
function _qhash2(h,s){
 for(var i=0;i<s.length;i++){
  h^=s.charCodeAt(i);h+=(h << 1)+(h << 4)+(h << 7)+(h << 8)+(h << 24);}
 return h;
}
function _qhash(s){
 var h1=0x811c9dc5,h2=0xc9dc5118;
 return (Math.round(Math.abs(_qhash2(h1,s)*_qhash2(h2,s))/65536)).toString(16);
}
function _qcsc(){
 var s="";var d=_qcdomain();
 if(_qad==1)return ";fpan=u;fpa=";
 var sd=["4dcfa7079941","127fdf7967f31","588ab9292a3f","32f92b0727e5","22f9aa38dfd3","a4abfe8f3e04","18b66bc1325c","958e70ea2f28","bdbf0cb4bbb","65118a0d557","40a1d9db1864","18ae3d985046","3b26460f55d"];
 var qh=_qhash(d);
 for(var i=0;i<sd.length;i++){if(sd[i]==qh)return ";fpan=u;fpa=";}
 var u=document;var a=_qcgc("__qca");
 if(a.length>0){s+=";fpan=0;fpa="+a;}
 else{
  var da=new Date();
  a='P0-'+_qcrnd()+'-'+da.getTime();
  u.cookie="__qca="+a+"; expires=Sun, 18 Jan 2038 00:00:00 GMT; path=/; domain="+d;
  a=_qcgc("__qca");
  if(a.length>0){s+=";fpan=1;fpa="+a;}
  else{s+=";fpan=u;fpa=";}
 }
 return s;
}
function _qcdc(n){
 document.cookie=n+"=; expires=Thu, 01 Jan 1970 00:00:01 GMT; path=/; domain="+_qcdomain();
}
function _qpxload(){
 if((_qimg)&& typeof _qimg.width =="number"){
  if (_qimg.width==3){_qcdc("__qca");}
}}
function _qcp(p, myqo)
{
 var s='',a=null;
 var media='webpage',event='load';
 if(myqo!=null){
  for(var k in myqo){
   if(typeof(k)!='string'){continue;}
   if(typeof(myqo[k])!='string'){continue;}
   if(k=='qacct'){
    a=myqo[k];
    continue;
   }
   s+=';'+k+p+'='+_qceuc(myqo[k]);
   if(k=='media'){media=myqo[k];}
   if(k=='event'){event=myqo[k];}
  }
 }
 if (typeof a !="string"){
  if((typeof _qacct =="undefined")||(_qacct.length==0))return'';
  a=_qacct;
 }
 if (media=='webpage' && event=='load'){
  for(var i=0;i<_qpixelsent.length;i++){
   if(_qpixelsent[i]==a)return'';
  }
  _qpixelsent.push(a);
 }
 if (media=='ad'){_qad=1;}
 s=';a'+p+'='+a+s;
 return s;
}
function quantserve(){
 var r=_qcrnd();
 var sr='',qo='',qm='',url='',ref='',je='u',ns='1';
 var qocount=0;
 _qad=0;
 if(typeof _qpixelsent =="undefined"){
  _qpixelsent= new Array();
 }
 if(typeof _qoptions !="undefined" && _qoptions!=null){
  var _qopts=_qoptions;_qoptions=null;
  for(var k in _qopts){
   if(typeof(_qopts[k])=='string'){
    qo=_qcp("", _qopts);
    break;
   }else if(typeof(_qopts[k])=='object' && _qopts[k]!=null){
    ++qocount;
    qo+=_qcp("."+qocount, _qopts[k]);
   }
  }
 }else if (typeof _qacct =="string"){
  qo=_qcp("",null);
 }
 if(qo.length==0)return;
 var ce=(navigator.cookieEnabled)?"1":"0";
 if(typeof navigator.javaEnabled !='undefined')je=(navigator.javaEnabled())?"1":"0";
 if(typeof _qmeta !="undefined" && _qmeta!=null){qm=';m='+_qceuc(_qmeta);_qmeta=null;}
 if(self.screen){sr=screen.width+"x"+screen.height+"x"+screen.colorDepth;}
 var d=new Date();
 var dst=_qcdst();
 var dg="P12080-W-FF-3";var qs="http://pixel.quantserve.com";
 var fp=_qcsc();
 if(window.location && window.location.href)url=_qceuc(window.location.href);
 if(window.document && window.document.referrer)ref=_qceuc(window.document.referrer);
 if(self==top)ns='0';
 _qimg=new Image();
 _qimg.alt="";
 _qimg.src=qs+'/pixel'+';r='+r+fp+';ns='+ns+';url='+url+';ref='+ref+';ce='+ce+';je='+je+';sr='+sr+';dg='+dg+';dst='+dst+';et='+d.getTime()+';tzo='+d.getTimezoneOffset()+qo+qm;
 _qimg.onload=function() {_qpxload();}
}
quantserve();

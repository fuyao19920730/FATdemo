using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BestHTTP;

public class Logic : MonoBehaviour
{

	private const string httpHost = "";
	
	// Use this for initialization
	void Start () {

	}
	
	// Update is called once per frame
	void Update () {
		
	}


	public void Register()
	{
		HTTPRequest registerReq = new HTTPRequest(new Uri(httpHost),HTTPMethods.Post,RegisterReqCallback);
		
		//请求头
		registerReq.AddHeader("Proto","jsx_json");
		registerReq.AddHeader("MsgCarrier","false");
		registerReq.AddHeader("Appid","Appid");
		registerReq.AddHeader("Time",GetTimeStampSeconds());
		registerReq.AddHeader("Pver","Pver");
		registerReq.AddHeader("Sign","Sign");
		registerReq.AddHeader("Session","Session");
		
		//请求body
		registerReq.AddField("name", "QRegisterId");
		registerReq.AddField("type", "type");
		registerReq.AddField("id", "id");
		registerReq.AddField("deviceid", "deviceid");

		
		registerReq.Send();
	}
	

	private void RegisterReqCallback(HTTPRequest originalrequest, HTTPResponse response)
	{
		throw new NotImplementedException();
	}
	
	
	private string GetTimeStampSeconds()
	{
		TimeSpan ts = DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0, 0);
		long ret = Convert.ToInt64(ts.TotalSeconds);
		return ret.ToString();
	}

    public void GetInfo()
    {
        DeviceInfo.GetDeviceInfo();
    }
}

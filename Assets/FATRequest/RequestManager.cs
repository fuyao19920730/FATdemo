using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace FATRequest
{
	//消息和request 的绑定
	public class RequestManager
	{

		private Dictionary<string,Request> Requests = new Dictionary<string, Request>();
		
		private static RequestManager instance;

		public static RequestManager GetManager()
		{
			if (null == instance)
			{
				instance = new RequestManager();
			}
			return instance;
		}

		//request创建后,注册到字典中,以便于绑定回调方法
		public void Register(string cmd, Request request)
		{
			if (Requests.ContainsKey(cmd))
			{
				Requests.Remove(cmd);
			}
			
			Requests.Add(cmd,request);
		}

		public void ReceiveMessage(string cmd, OnRequestFinishedDelegate finishedDelegate)
		{
			Request req = Requests[cmd];

		}

		public void CancelReceiveMessage(string cmd,OnRequestFinishedDelegate finishedDelegate)
		{
			Request req = Requests[cmd];
		}
	}
}


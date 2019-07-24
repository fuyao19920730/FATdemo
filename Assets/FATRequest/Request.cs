using System.Collections.Generic;
using System;
using System.Diagnostics;
using BestHTTP;
using Org.BouncyCastle.Asn1.Ocsp;

namespace FATRequest
{
    public enum ProtocolType
    {
        Http,
        Websocket
    }

    public enum SerializationType
    {
        Json,
        ProtoBuffer
    }

    
    public delegate void OnRequestFinishedDelegate(Request request,object response);

    public class Request
    {
        public event OnRequestFinishedDelegate Response;
        
        public string serverUrl;

        private string message;
        
        private object parameters;
        
        private ProtocolType protocolType;

        private SerializationType serializationType;

        public FATHttpMethods httpMethod;


        //接受请求的配置参数
        public Request(string message,object parameters,ProtocolType protocolType,SerializationType serializationType)
        {
            this.message = message;
            this.parameters = parameters;
            this.protocolType = protocolType;
            this.serializationType = serializationType;
            //初始化成功后添加到消息字典中
            RequestManager.GetManager().Register(message,this);
        }

        //发送请求
        public void Send()
        {
            switch (protocolType)
            {
                case ProtocolType.Http:
                    HttpRequestManager httpRequestManager = new HttpRequestManager(serverUrl ?? NetConfig.defaultHttpHost);
                    httpRequestManager.parameters = parameters;
                    httpRequestManager.methods = httpMethod;
                    httpRequestManager.Send();
                    httpRequestManager.response = HttpResponse;
                    break;
                case ProtocolType.Websocket:
                    WebSocketManager webSocketManager = WebSocketManager.GetInstance();
                    break;
                default:
                    break;
            }
        }

        private void HttpResponse(HttpRequestManager httprequst, object response)
        {
            if (null != Response)
            {
                
            }
        }
    }

}


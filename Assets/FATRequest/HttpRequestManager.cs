using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;
using BestHTTP;

namespace FATRequest
{
    public enum FATHttpMethods
    {
        Get,
        Head,
        Post,
        Put,
        Delete,
        Patch,
        Merge
    }


    //序列化的工作在这里做好,返回出去的数据是解析好的
    public class HttpRequestManager
    {
        public delegate void OnHttpFinishedDelegate(HttpRequestManager httpRequst, object response);

        public OnHttpFinishedDelegate response;
        private HTTPRequest httpReq;
        public FATHttpMethods methods;
        public object parameters;
        public SerializationType serializationType; 

        public HttpRequestManager(string url)
        {
            httpReq = new HTTPRequest(new Uri(url),Callback);
        }

        public void Send()
        {
            httpReq.MethodType = ConvertMethod(methods);
            httpReq.RawData = GetRawData();
            httpReq.Send();
        }
        

        public void AddHeaderFields(Dictionary<string, string> fields)
        {
            foreach (KeyValuePair<string,string> kvp in fields)
            {
                AddHeaderField(kvp.Key,kvp.Value);
            }
        }

        public void AddHeaderField(string headerName, string headerValue)
        {
            httpReq.AddHeader(headerName,headerValue);
        }
        

        private void Callback(HTTPRequest originalrequest, HTTPResponse resp)
        {
            if (response != null)
            {
                response(this, GetObjectFromData(resp.Data));
            }
        }

        private HTTPMethods ConvertMethod(FATHttpMethods method)
        {
            HTTPMethods m = HTTPMethods.Get;
            switch (method)
            {
                case FATHttpMethods.Get:
                    m = HTTPMethods.Get;
                    break;
                case FATHttpMethods.Post:
                    m = HTTPMethods.Post;
                    break;  
                default:break;
            }
            return m;
        }

        private byte[] GetRawData()
        {
            byte[] rawData = null;
            switch (serializationType)
            {
                case SerializationType.Json:
                    rawData = JsonTool.JsonDataFromObject(parameters);
                    break;
                case SerializationType.ProtoBuffer:
                    break;
                default:
                    break;
            }
            return rawData;
        }


        private object GetObjectFromData(byte[] data)
        {
            object obj = null;
            switch (serializationType)
            {
                case SerializationType.Json:
                    obj = JsonTool.ObjectFromJsonData(data);
                    break;
                case SerializationType.ProtoBuffer:
                    break;
                default:
                    break;
            }
            return obj; 
        }
    }
}


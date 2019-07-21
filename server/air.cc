#include <node.h>
#include <node_buffer.h>

#include "irext/include/ir_decode.h"

namespace demo{
    using v8::FunctionCallbackInfo;
    using v8::Isolate;
    using v8::Local;
    using v8::Object;
    using v8::String;
    using v8::Value;
    using v8::Number;
    using v8::Array;

    void decode(const FunctionCallbackInfo<Value>& args) {
        Isolate* isolate = args.GetIsolate();
        UINT16 user_data[512];
        t_remote_ac_status ac_status;
        Local<Object> bufferObj = args[0]->ToObject();
        Local<Number> power = Local<Number>::Cast(args[1]);
        Local<Number> mode = Local<Number>::Cast(args[2]);
        Local<Number> temperature = Local<Number>::Cast(args[3]);

        // int length = contentStr->Length(); 

        int length = node::Buffer::Length(bufferObj); 
        UINT8 *content = (UINT8 *)malloc(length * sizeof(UINT8));
        content = (UINT8 *)node::Buffer::Data(bufferObj);

        // contentStr->WriteUtf8(isolate, content, length);
        // String::Utf8Value ut8value(isolate, contentStr);
        // content = (UINT8 *) *ut8value;

        INT8 ret = ir_binary_open(IR_CATEGORY_AC, 1, content, length);
        // printf("ret -> %d", ret);
        ac_status.ac_power = t_ac_power(power->NumberValue());
        ac_status.ac_mode = t_ac_mode(mode->NumberValue());
        if (temperature->NumberValue() > 16) {
          ac_status.ac_temp = t_ac_temperature(temperature->NumberValue() - 16); 
        }
        length = ir_decode(2, user_data, &ac_status, 0);
        ir_close();

        Local<Array> arr = Array::New(isolate);
        for (int i = 0; i < length; i++) {
          arr->Set(i, Number::New(isolate, user_data[i]));
        }
        args.GetReturnValue().Set(arr);
    }


    void init(Local<Object> exports){
        NODE_SET_METHOD(exports, "decode", decode);
    }

    NODE_MODULE(addon, init)
}
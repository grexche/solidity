// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
library IterableMapping{
    struct Map{
        address[] keys;
        mapping(address=>uint) values;
        mapping(address=>uint) indexOf;
        mapping(address=>bool) inserted;
    }

    function get(Map storage map,address key) public view returns(uint){
        return map.values[key];
    }

    function getKeyAtIndex(Map storage map,uint index) public view returns(address){
        return map.keys[index];
    }

    function size(Map storage map) public view returns(uint){
        return map.keys.length;
    }

    function set(Map storage map,address key,uint val)public{
        if(map.inserted[key]){
            map.values[key]=val;
        }else{
            map.inserted[key]=true;
            map.values[key]=val;
            map.indexOf[key]=map.keys.length;
            map.keys.push(key);
        }
    }
    //主要逻辑就是把最后一个key的关系移到被删除的key上
    function remove(Map storage map,address key)public{
        if(!map.inserted[key]){
            return;
        }
        //先移除key的值并表示为未被插入
        delete map.inserted[key];
        delete map.values[key];

        //获取当前要移除的key的index，准备将最后一个key移到该index上和最后一个key的自身和index
        uint index=map.indexOf[key];
        uint lastIndex=map.keys.length-1;
        address lastKey=map.keys[lastIndex];
        //修改最后一个key的映射关系，删除应删除key的index映射
        map.indexOf[lastKey]=index;
        delete map.indexOf[key];
        //将最后一个key赋值到位于被删除index上
        map.keys[index]=lastKey;
        map.keys.pop();
    }


}

contract TestIterableMap{
    using IterableMapping for IterableMapping.Map;

    IterableMapping.Map private map;

    function testIterableMap() public{
        map.set(address(0),0);
        map.set(address(1),100);
        map.set(address(2),200);
        map.set(address(2),200);
        map.set(address(3),300);

        for(uint i=0;i<map.size();i++){
            address key=map.getKeyAtIndex(i);

            assert(map.get(key)==i*100);
        }

        map.remove(address(1));

        assert(map.size()==3);
        assert(map.getKeyAtIndex(0)==address(0));
        assert(map.getKeyAtIndex(1)==address(3));
        assert(map.getKeyAtIndex(2)==address(2));
    }
}
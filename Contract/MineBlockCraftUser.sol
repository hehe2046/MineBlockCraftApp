pragma solidity >=0.4.22 <0.7.0;
pragma experimental ABIEncoderV2;

contract Owner {

    address public owner;
    

    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    constructor() public {
        owner = msg.sender; 
        emit OwnerSet(address(0), owner);
    }

    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

}

contract MBCUser is Owner {
    
    struct Profile{
        string Nickname;
        string Signature;
    }
    
    Profile[] public Profiles;
    
    mapping(uint => address) public IdToAddress;
    mapping(address => uint) public AddressToId;
    mapping(address => address[]) internal Friend;
    
    uint public userCount;
    
    event eventNewUser(address indexed userAddress, uint indexed UserId);
    
    modifier isUser() {
        require(AddressToId[msg.sender]>0 || msg.sender==owner ,'not registered');
        _;
    }

    function _newUser(string memory _Nickname,string memory _Signature) internal returns(uint _userId){
        Profiles.push(Profile(_Nickname, _Signature));
        uint UserId = Profiles.length - 1;
        
        IdToAddress[UserId] = msg.sender;
        AddressToId[msg.sender] = UserId;
        userCount++;
        
        emit eventNewUser(msg.sender,UserId);
        
        return UserId;
    }
    
    function newUser(string memory _Nickname,string memory _Signature) public returns(uint _userId){
        require(AddressToId[msg.sender]==0 && msg.sender != owner,'already registered');
        return _newUser(_Nickname,_Signature);
    }
    
    function editProfile(string memory _Nickname,string memory _Signature) public {
        require(AddressToId[msg.sender]>0 , 'not registered');
        uint UserId = AddressToId[msg.sender];
        Profiles[UserId] = Profile(_Nickname, _Signature);
    }
    
    function newProfile(string memory _Nickname,string memory _Signature) public returns(uint _userId){
        require(msg.sender != owner,'you are owner');
        if(AddressToId[msg.sender]==0){
            return _newUser(_Nickname,_Signature);
        }else{
            editProfile(_Nickname,_Signature);
            return AddressToId[msg.sender];
        }
    }
    
    function getProfile(address _address) public view returns(Profile memory){
        if (_address == owner){
            return Profiles[0];
        }else if(AddressToId[_address] > 0){
            return Profiles[AddressToId[_address]];
        }else{
            return Profile("", "");
        }
    }
}

contract MBCMessage is MBCUser {
    
    struct Message {
        uint time;
        string content;
        address fromUser;
        address toUser;
    }
    
    Message[] public Messages;
    
    mapping(address => mapping(address => uint)) public messageCount;
    mapping(address=>address[]) internal messageList;
    
    event newMessage(address indexed fromUser, address indexed toUser, uint MessageId);
    
    function sendMsg(address _toUser, string memory _content) public {
        require(_toUser != msg.sender ,'Can not send to yourself');
        //推入消息列表
        Messages.push(Message(now,_content,msg.sender,_toUser));
        uint MessageId = Messages.length - 1;
        emit newMessage(msg.sender,_toUser,MessageId);
        messageList[msg.sender] = _updatemessageList(msg.sender,_toUser);
        messageList[_toUser] = _updatemessageList(_toUser,msg.sender);
        
        messageCount[msg.sender][_toUser]++;
        messageCount[_toUser][msg.sender]++;
        delete _content;
    }
    
    function _updatemessageList(address _fromUser,address _toUser) view internal returns(address[] memory){
        bool exists = false;
        for (uint i = 0; i < messageList[_fromUser].length; i++) {
            if (messageList[_fromUser][i] == _toUser) {
                exists = true;
            }
        }
        
        address[] memory messages = new address[](exists ? messageList[_fromUser].length : messageList[_fromUser].length+1);

        messages[0] = _toUser;
        for (uint i = 0; i < messageList[_fromUser].length; i++) {
            if (messageList[_fromUser][i] != _toUser) {
                messages[i+1] = messageList[_fromUser][i];
            }
        }
        
        return messages;
    }
    
    function getMessages(address _toUser) public view returns(Message[] memory){
        Message[] memory result = new Message[](messageCount[msg.sender][_toUser]);
        
        uint counter = 0;
        for(uint i=0;i<Messages.length;i++){
            if((Messages[i].fromUser == msg.sender && 
                Messages[i].toUser == _toUser ) ||
                (Messages[i].fromUser == _toUser &&
                Messages[i].toUser == msg.sender)){
                    result[counter] = Messages[i];
                    counter++;
                }
        }
        return result;
    }
    
    function msgList() public view returns(address[] memory){
        return messageList[msg.sender];
    }
}

contract MBCFriend is MBCUser,MBCMessage {

    event eventAddFriend(address indexed fromUser, address indexed toUser);
    
    function addFriend(address _toUser)public{
        require(!isFriends(_toUser) ,'already is your friend');
        Friend[msg.sender].push(_toUser);
        messageList[msg.sender] = _updatemessageList(msg.sender,_toUser);
        emit eventAddFriend(msg.sender,_toUser);
    }
    
    function getFriends() public view returns(address[] memory){
        return Friend[msg.sender];
    }
    
    function isFriends(address _toUser) public view returns(bool){
        bool exists = false;
        for (uint i = 0; i < Friend[msg.sender].length; i++) {
            if (Friend[msg.sender][i] == _toUser) {
                exists = true;
            }
        }
        return exists;
    }
}


contract MBCCore is Owner,MBCUser,MBCFriend {
            
    constructor() public {
        _newUser("Fankouzu","I'm admin");
    }
}


























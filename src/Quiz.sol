// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


import "forge-std/Test.sol";


contract Quiz{
    struct Quiz_item {
      uint id;
      string question;
      string answer;
      uint min_bet;
      uint max_bet;
   }
    
    mapping(address => uint256)[] public bets;
    uint public vault_balance;

    address owner; 
    uint256 quiz_index = 0;

    mapping(uint256 => Quiz_item) public quiz_list;
    mapping(uint256 => string) private quiz_answer;
    mapping(uint256 => bytes32) private quiz_answer_hash;

		
		mapping(address => uint256) private answer_money;

    constructor () {
        owner = msg.sender;  

        Quiz_item memory q;
        q.id = 1;
        q.question = "1+1=?";
        q.answer = "2";
        // q.answer_hash = 0;
        q.min_bet = 1 ether;
        q.max_bet = 2 ether;
        addQuiz(q);
    }


    function keccakHash(string memory _str) public pure returns (bytes32) {
        return keccak256(abi.encode(_str));
    }



    function addQuiz(Quiz_item memory q) public {
        require(msg.sender == owner);
      
        quiz_answer[q.id] = q.answer;
        quiz_answer_hash[q.id] = keccakHash(q.answer);
        q.answer = "";

        quiz_index = quiz_index + 1;

        quiz_list[quiz_index] = q;

        bets.push();
    }


    function getAnswer(uint quizId) public view returns (string memory){
        return quiz_answer[quizId];
    }


    function getQuiz(uint quizId) public view returns (Quiz_item memory) {
        return quiz_list[quizId];
    }


    function getQuizNum() public view returns (uint){
        return quiz_index;
    }
    

    function betToPlay(uint quizId) public payable {
        require(quiz_list[quizId].min_bet <= msg.value);
        require(msg.value <= quiz_list[quizId].max_bet);
   
        bets[quizId-1][msg.sender] += msg.value;
    }


    function solveQuiz(uint quizId, string memory ans) public returns (bool) {
        if(quiz_answer_hash[quizId] == keccakHash(ans)){
            answer_money[msg.sender] = answer_money[msg.sender] + bets[quizId-1][msg.sender];

            return true;
        } else {
            vault_balance += bets[quizId-1][msg.sender];
            bets[quizId-1][msg.sender] = 0;

            return false;
        }
    }


    function claim() public {
        require(answer_money[msg.sender] <= address(this).balance);

        if(answer_money[msg.sender] > 0) {
            payable(msg.sender).call{value: answer_money[msg.sender] * 2}(""); 
        }
        answer_money[msg.sender] = 0;
    }


    fallback() external payable {}
}
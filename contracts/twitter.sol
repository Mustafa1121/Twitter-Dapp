// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity ^0.8.18;

contract Profile {
    struct UserProfile {
        string displayName;
        string bio;
    }

    mapping(address => UserProfile) public profiles;

    function setProfile(string memory _dislpayName, string memory _bio) public {
        profiles[msg.sender] = UserProfile(_dislpayName, _bio);
    }

    function getProfile(
        address _user
    ) public view returns (UserProfile memory) {
        return profiles[_user];
    }
}

interface IProfile {
    struct UserProfile {
        string displayName;
        string bio;
    }

    function getProfile(address _user) external view returns (UserProfile memory);

}

contract Twitter is Ownable {
    uint16 public MAX_TWEET_LENGTH = 280;

    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    mapping(address => Tweet[]) public tweets;
    IProfile profileContract;

    event TweetCreated(
        uint256 id,
        address author,
        string ccontent,
        uint256 timestamp
    );
    event TweetLiked(
        address liker,
        address tweetAuthor,
        uint256 tweetId,
        uint256 newLikeCount
    );
    event TweetUnLiked(
        address liker,
        address tweetAuthor,
        uint256 tweetId,
        uint256 newLikeCount
    );

    modifier onlyRegister() {
        IProfile.UserProfile memory userProfileTemp = profileContract.getProfile(msg.sender);
        require(bytes(userProfileTemp.displayName).length > 0,"User not registered yet");
        _;
    }

    constructor(address _profileContract) {
        profileContract = IProfile(_profileContract);
    }

    function getTotalLikes(address _author) external view returns (uint) {
        uint totalLikes = 0;

        for (uint i = 0; i < tweets[_author].length; i++) {
            totalLikes += tweets[_author][i].likes;
        }

        return totalLikes;
    }

    function createTweet(string memory _tweet) public  onlyRegister{
        // condition if tweet length <= 280 good otherwise we revert
        require(bytes(_tweet).length <= MAX_TWEET_LENGTH, "Tweet is too long!");

        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });
        tweets[msg.sender].push(newTweet);
        emit TweetCreated(
            newTweet.id,
            newTweet.author,
            newTweet.content,
            newTweet.timestamp
        );
    }

    function likeTweet(address _author, uint256 _id) external onlyRegister {
        require(tweets[_author][_id].id == _id, "TWEET DOES NOT EXIST");
        tweets[_author][_id].likes++;
        emit TweetLiked(msg.sender, _author, _id, tweets[_author][_id].likes);
    }

    function UnlikeTweet(uint256 _id, address _author) external onlyRegister {
        require(tweets[_author][_id].id == _id, "TWEET DOES NOT EXIST");
        require(tweets[_author][_id].likes > 0, "TWEET HAS NO LIKE");
        tweets[_author][_id].likes--;
        emit TweetUnLiked(msg.sender, _author, _id, tweets[_author][_id].likes);
    }

    function changeTweetLength(uint16 _newTweetLength) public onlyOwner {
        MAX_TWEET_LENGTH = _newTweetLength;
    }

    function getTweet(uint _i) public view returns (Tweet memory) {
        return tweets[msg.sender][_i];
    }

    function getAllTweets(address _owner) public view returns (Tweet[] memory) {
        return tweets[_owner];
    }
}

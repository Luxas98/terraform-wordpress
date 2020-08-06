/*jslint es6:true*/

import React from 'react';
import logo from './logo.svg';
import './App.css';
import config from './config.json';

import TwitterLogin from 'react-twitter-auth';
import FacebookLogin from 'react-facebook-login';
import { GoogleLogin } from 'react-google-login';

class MainApp extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            currentTime: 0,
            isAuthenticated: false,
            user: null,
            token: ''
        };
    }

    logout() {
        this.setState({isAuthenticated: false, token: '', user: null});
    }

    twitterResponse(response) {}

    facebookResponse(response) {
        console.log(response);
    }

    googleResponse(response) {
        console.log(response);
    }

    onFailure(error) {
      alert(error);
    }

    setCurrentTime(datatime) {
        this.setState({currentTime: datatime});
    }

    componentDidMount() {
        fetch('/time').then(res => res.json()).then(data => {
            this.setCurrentTime(data.time);
        });
    }

    render() {
        let content = !!this.state.isAuthenticated ?
            (
                <div>
                    <p>Authenticated</p>
                    <div>
                        {this.state.user.email}
                    </div>
                    <div>
                        <button onClick={this.logout} className="button">
                            Log out
                        </button>
                    </div>
                </div>
            ) :
            (
                <div>
                    <TwitterLogin loginUrl="http://localhost:4000/api/v1/auth/twitter"
                                   onFailure={this.twitterResponse} onSuccess={this.twitterResponse}
                                   requestTokenUrl="http://localhost:4000/api/v1/auth/twitter/reverse"/>
                    <FacebookLogin
                        appId={config.FACEBOOK_APP_ID}
                        autoLoad={false}
                        fields="name,email,picture"
                        callback={this.facebookResponse} />
                    <GoogleLogin
                        clientId="XXXXXXXXXX"
                        buttonText="Login"
                        onSuccess={this.googleResponse}
                        onFailure={this.googleResponse}
                    />
                </div>
            );

        return (
            <div className="App">
              <header className="App-header">
                <img src={logo} className="App-logo" alt="logo" />
                <p>
                  Edit <code>src/App.js</code> and save to reload.
                </p>
                <a
                  className="App-link"
                  href="https://reactjs.org"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Learn React
                </a>
              </header>
                <p>The current time is {this.state.currentTime}.</p>
                {content}
            </div>
        )
    }
}

export default MainApp;

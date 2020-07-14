import React from 'react';
import logo from './logo.svg';
import './App.css';

class MainApp extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            currentTime: 0
        };
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
            </div>
        )
    }
}

export default MainApp;

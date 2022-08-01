import React, { useEffect,useState } from "react";
import { useIntl } from "react-intl";
import "./MainContent.css";
import Dashboard from "../Dashboard/Dashboard";
import { Button } from "@chakra-ui/react";
import CDPs from '../CDPs/CDPs'

export default function MainContent({onJoin,show}) {
  const intl = useIntl();

  const [join,setJoin]=useState(false)

  const joinTheFight=()=>{
    setJoin(true)
    onJoin(true)
  }

  useEffect(() => {}, []);

  return (
    <div className={join ? "container2" : "container1"}>
      <div className="subcontainer animated bounceIn">
        <div className="content">
          <div className="top-left"></div>
          <div className="left-bot"></div>
          <div className="bot-right"></div>
          <div className="right-top"></div>
        </div>
        <div className="block  style-11">
          {!join &&<><h1>Resistance</h1>
          <Button variant="ghost" className="btn" onClick={joinTheFight}>
            Join the fight
          </Button></>}
        </div>
      </div>
      <div className="center-div">{join && <>{ show==="Dashboard" && <Dashboard />}{ show==="CDPs" && <CDPs></CDPs>}</>}</div>
    </div>
  );
}

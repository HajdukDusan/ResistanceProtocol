import React from "react";
import { useState, useEffect } from "react";
import Sidebar from "../Sidebar/Sidebar";
import MainContent from "../MainContent/MainContent";
import "./Homepage.scss";
import { useWeb3React } from "@web3-react/core";
import MyModal from "../MyModal/MyModal";
import Toolbar from "../Toolbar/Toolbar";
import Footer from "../Footer/Footer";

export default function Homepage() {
  const [openModal, setOpenModal] = useState(false);
  const [contract, setContract] = useState();
  const { library, chainId, account, deactivate, active } = useWeb3React();
  const [join, setJoin] = useState(false);
  const [show, setShow] = useState("Dashboard");

  const closeModal = () => {
    setOpenModal(false);
  };

  const refreshState = () => {
    window.localStorage.setItem("provider", undefined);
  };

  const disconnect = () => {
    refreshState();
    deactivate();
  };

  useEffect(() => {
    if (library) {
    }
  }, [library]);
  return (
    <div className={`app `}>
      <MyModal open={openModal} handleClose={closeModal}></MyModal>
      {false && (
        <Sidebar
          onOpenModal={setOpenModal}
          onDisconnect={disconnect}
          setShow={setShow}
        />
      )}
      <MainContent onJoin={setJoin} show={show} />
      {join && <Toolbar onOpenModal={setOpenModal} setShow={setShow} show={show} onDisconnect={disconnect}></Toolbar>}
    </div>
  );
}

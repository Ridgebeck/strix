class NewData {
  bool newSocial = false;
  bool newMessages = false;
  bool newImages = false;
  // bool newAudioFiles = false;
  // bool newVideos = false;
  // bool newReports = false;

  // return true if any new data exists
  bool anyNewData() {
    if (newSocial || newMessages || newImages) {
      return true;
    } else {
      return false;
    }
  }
}

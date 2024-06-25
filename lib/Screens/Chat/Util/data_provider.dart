import '../Model/lms_model.dart';

List<LMSModel> maanGetChatList() {
  List<LMSModel> list = [];
  list.add(LMSModel(title: 'John Wick', subTitle: 'hello', image: "https://assets.iqonic.design/old-themeforest-images/prokit/datingApp/Image.9.jpg"));
  list.add(LMSModel(title: 'Bella Hadid', subTitle: 'How ypu doing?', image: "https://assets.iqonic.design/old-themeforest-images/prokit/datingApp/Image.2.jpg"));
  list.add(LMSModel(title: 'Nora fatehi', subTitle: 'About what Course?', image: "https://assets.iqonic.design/old-themeforest-images/prokit/datingApp/Image.8.jpg"));
  list.add(LMSModel(title: 'Cristin', subTitle: 'About what Course?', image: "https://assets.iqonic.design/old-themeforest-images/prokit/datingApp/Image.1.jpg"));
  list.add(LMSModel(title: 'Chris Hameshorth', subTitle: 'hello', image: "https://assets.iqonic.design/old-themeforest-images/prokit/datingApp/Image.3.jpg"));
  list.add(LMSModel(title: 'Eliyahou Amoyelle', subTitle: 'How ypu doing?', image: "https://assets.iqonic.design/old-themeforest-images/prokit/datingApp/Image.4.jpg"));
  list.add(LMSModel(title: 'Nora fatehi', subTitle: 'About what Course?', image: "https://assets.iqonic.design/old-themeforest-images/prokit/datingApp/Image.8.jpg"));
  list.add(LMSModel(title: 'Izzy Sruly', subTitle: 'About what Course?', image: "https://assets.iqonic.design/old-themeforest-images/prokit/datingApp/Image.6.jpg"));
  list.add(LMSModel(title: 'Tom Holland', subTitle: 'hello', image: "https://assets.iqonic.design/old-themeforest-images/prokit/datingApp/Image.5.jpg"));
  list.add(LMSModel(title: 'Nora fatehi', subTitle: 'About what Course?', image: "https://assets.iqonic.design/old-themeforest-images/prokit/datingApp/Image.8.jpg"));
  list.add(LMSModel(title: 'Salma Hayek', subTitle: 'How ypu doing?', image: "https://assets.iqonic.design/old-themeforest-images/prokit/datingApp/Image.7.jpg"));
  list.add(LMSModel(title: 'Nora fatehi', subTitle: 'About what Course?', image: "https://assets.iqonic.design/old-themeforest-images/prokit/datingApp/Image.8.jpg"));
  return list;
}

List<LMSInboxData> maanInboxChatDataList() {
  List<LMSInboxData> list = [];
  list.add(LMSInboxData(id: 0, message: 'i have already taken medicine'));
  list.add(LMSInboxData(id: 1, message: 'Hi Kaixa, have you taken your pills yet?'));
  list.add(LMSInboxData(id: 1, message: 'sorry but i can\'t find your home number'));
  list.add(LMSInboxData(id: 0, message: 'Please knock on dor'));
  list.add(LMSInboxData(id: 0, message: 'I am home waiting for you'));
  list.add(LMSInboxData(id: 0, message: 'Hi Miranda'));
  list.add(LMSInboxData(id: 1, message: 'I am on my way to your home visit'));
  return list;
}

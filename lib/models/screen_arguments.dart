//ToDo: I don't like this method

class SearchProviderScreenArguments {
  final String service;

  SearchProviderScreenArguments(this.service);
}


class EditProviderAccountScreenArguments {
  final bool fromRegistration;

  EditProviderAccountScreenArguments({this.fromRegistration = false});
}

//TODO: must find a better way to do this
//TODO: or find a way to only pass argument if you need to change a value (preinitialise)
class HomeScreenArguments {

  final int startingIndex;

  HomeScreenArguments({this.startingIndex = 0});
}
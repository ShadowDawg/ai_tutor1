String capitalize(String inputString) {
  // Split the input string into words
  var words = inputString.split(' ');
  // Capitalize the first letter of each word and join them back into a string
  var capitalizedWords = words.map((word) {
    if (word.isNotEmpty) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }
    return word;
  }).join(' ');
  return capitalizedWords;
}

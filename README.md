# MarvelComics

Overview

The Marvel Comics App allows users to browse, search, and manage a collection of comics using data fetched from the Marvel API. Users can mark comics as favorites and store them locally using Core Data. The app features functionality for searching comics, viewing details about comics, and managing a personal list of favorite comics.
Main Features:
* Fetch and display comics from the Marvel API.
* Search through comics.
* Mark comics as favorites and store them locally in Core Data.
* Fetch detailed information about comic variants and creators.
* Remove comics from favorites.

Table of Contents
1. Core Components
    * fetchComics()
    * fetchCreatorDetail(resourceURI:)
    * fetchAllVariants(variants:completion:)
    * comicFromEntity(_:)
    * saveComic(_:)
    * checkIfFavorite()
    * removeFromFavorites()
    * loadComics()
    * deleteComic(_:)
2. Search Functionality
    * setupSearchListener()
    * searchComics()
3. Error Handling
    * Error messages and handling mechanisms.
4. Core Data Management
    * Storing, retrieving, and deleting comics from Core Data.
    * Managing favorites with Core Data.
5. Marvel API Interaction
    * Fetching comic and creator data from the API.
    * Handling asynchronous data requests with Combine.


1. Core Components

fetchComics()
* Description: Fetches a list of comics from the Marvel API and updates the UI state (e.g., loading status, comics list).
* Implementation: Uses Combine's AnyPublisher to fetch the data asynchronously, handle errors, and update the UI on the main thread.

fetchCreatorDetail(resourceURI:)
* Description: Fetches detailed information about a creator from the Marvel API using the provided resource URI.
* Implementation: Replaces http: with https: in the resource URI and performs an asynchronous API request. Updates the creatorDetail on success.

fetchAllVariants(variants:completion:)
* Description: Fetches all comic variants from an array of ComicSummary objects using their resource URIs.
* Implementation: Uses DispatchGroup to synchronize multiple asynchronous API requests and calls the completion handler when all variants are fetched.

comicFromEntity(_:)
* Description: Converts a ComicEntity from Core Data into a Comic object for use in the app.
* Implementation: Extracts values from ComicEntity, including handling missing data like the thumbnail, variants, and creators.
* 
saveComic(_:)
* Description: Saves a Comic object to Core Data by creating a new ComicEntity.
* Implementation: Creates a new ComicEntity, assigns the values, and saves the context.

checkIfFavorite()
* Description: Checks if the current comic is marked as a favorite by searching Core Data for the comic’s ID.
* Implementation: Executes a fetch request and sets isFavorite if the comic is found in Core Data.

removeFromFavorites()
* Description: Removes a comic from Core Data by deleting the corresponding ComicEntity.
* Implementation: Searches for the comic by its ID and deletes it from Core Data.

loadComics()
* Description: Loads all comics stored in Core Data and converts them into an array of Comic objects.
* Implementation: Fetches all ComicEntity records, converts them into Comic objects, and returns the list.

deleteComic(_:)
* Description: Deletes a specific ComicEntity from Core Data.
* Implementation: Deletes the entity and saves the context.

2. Search Functionality

setupSearchListener()
* Description: Listens for changes to the search query and triggers a search after a debounce period.
* Implementation: Uses Combine to debounce input and avoid redundant searches.

searchComics()
* Description: Filters the comics list based on the current search query.
* Implementation: Resets the filtered list if the query is empty, otherwise filters by comic title.

3. Error Handling
Error handling is integrated throughout the app using do-catch blocks and Combine's sink operators. Errors are logged to the console, and appropriate messages can be displayed to users when necessary.

3. Error Handling
Error handling is integrated throughout the app using do-catch blocks and Combine's sink operators. Errors are logged to the console, and appropriate messages can be displayed to users when necessary.

5. Marvel API Interaction
The app interacts with the Marvel API to fetch data such as comic lists, variants, and creator details. The app handles API requests asynchronously using Combine. Key functions include:
* Fetching comics: fetchComics()
* Fetching creator details: fetchCreatorDetail(resourceURI:)
* Fetching comic variants: fetchAllVariants(variants:completion:)


Conclusion
This documentation provides an overview of the key components of the Marvel Comics App, covering API interaction, Core Data management, search functionality, and error handling. Each method is documented for easy reference and future development.


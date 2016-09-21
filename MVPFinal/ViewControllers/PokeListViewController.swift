//
//  PokeListViewController.swift
//  MVPStart
//
//  Created by Maxi Casal on 8/11/16.
//  Copyright © 2016 Maxi Casal. All rights reserved.
//

import UIKit

class PokeListViewController: UIViewController {

  @IBOutlet var loadingView: UIView!
  @IBOutlet var pokemonTableView: UITableView!

  private let kPokeCellIdentifier = "kPokeCellIdentifier"
  private var pokemons = [Pokemon]()
  private let searchController = UISearchController(searchResultsController: nil)
  private var filteredPokemons = [Pokemon]()
  private var lastPokemon = 1
  private var presenter = PokeListPresenter()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupSearchController()
    presenter.attachView(self)
    presenter.getInitialPokemons()
  }
}

extension PokeListViewController: UITableViewDataSource, UITableViewDelegate {

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return isSearching() ? filteredPokemons.count : pokemons.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let pokemon = isSearching() ? filteredPokemons[indexPath.row] : pokemons[indexPath.row]
    let cell = tableView.dequeueReusableCellWithIdentifier(kPokeCellIdentifier, forIndexPath: indexPath) as! PokeTableViewCell
    cell.configure(pokemon)

    return cell
  }

  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    let lastSextionIndex = tableView.numberOfSections - 1
    let lastIndexRow = tableView.numberOfRowsInSection(lastSextionIndex) - 1
    if indexPath.row == lastIndexRow && indexPath.section == lastSextionIndex {
      self.getNextPokemons()
    }
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    let svc = segue.destinationViewController as! PokemonDetailViewController
    let indexPath = pokemonTableView.indexPathForSelectedRow
    svc.pokemon = isSearching() ? filteredPokemons[indexPath!.row] : pokemons[indexPath!.row]
  }
}

extension PokeListViewController: UISearchResultsUpdating {

  func setupSearchController() {
    searchController.searchBar.frame = CGRectMake(0, 0, pokemonTableView.bounds.width, 30)
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
    pokemonTableView.tableHeaderView = searchController.searchBar
  }

  func filterContentForSearchText(searchText: String, scope: String = "All") {
    searchController.dimsBackgroundDuringPresentation = true
    filteredPokemons = pokemons.filter({ pokemon in

      return pokemon.name!.lowercaseString.containsString(searchText.lowercaseString)
    })

    pokemonTableView.reloadData()
    searchController.dimsBackgroundDuringPresentation = false
  }

  func isSearching() -> Bool {
    return searchController.active && searchController.searchBar.text != ""
  }

  func updateSearchResultsForSearchController(searchController: UISearchController) {
    filterContentForSearchText(searchController.searchBar.text! )
  }
}

extension PokeListViewController : PokeListView {

  func getInitialPokemons() {
    presenter.getInitialPokemons()
  }

  func addPokemon(pokemon: Pokemon) {
    lastPokemon = pokemon.id!
    pokemons.append(pokemon)
    pokemonTableView.reloadData()
  }

  private func getNextPokemons() {
    if pokemons.count == lastPokemon {
      let range = lastPokemon+1
      presenter.getNextPokemons(range)
    }
  }
}

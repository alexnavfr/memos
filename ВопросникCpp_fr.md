# Вопросник по С++ (fr)

1. Expliquez la différence entre `std::move` et `std::forward`. Quand utilise-t-on chacun ?
2. En C++17, que permet if constexpr comparé à un simple if ? Donnez un cas d’usage pertinent.
3. Quel est l'intérêt d'utiliser explicit dans un constructeur ? Pourquoi cette règle est importante en conception ?
4. Qu’est-ce qu’un SFINAE et comment peut-on l'utiliser pour activer/désactiver des fonctions ?
5. Quelle est la différence entre `override`, `final` et `virtual`? Que se passe-t-il si on oublie override?
6. Comment implémenteriez-vous un pattern Visitor moderne en C++ (C++17 ou plus) ?
7. Expliquez la règle des 5,3 ou 0 en C++. Pourquoi est-elle importante aujourd’hui ?
8. Quelle est votre approche pour concevoir une API C++ robuste et facile à maintenir ?
9. Comparez les avantages et inconvénients des `std::unique_ptr`, `std::shared_ptr`et raw pointers. Quand éviteriez-vous `shared_ptr`?
10. Comment implémenteriez-vous un plugin système (chargement dynamique de classes) en C++ moderne ?
11. Expliquez le coût réel d’un appel `virtuel`. Comment peut-on le contourner dans une application à haute performance ?
12. Comment profileriez-vous une application C++ ? Quels outils recommanderiez-vous (Linux ou Windows) ?
13. Quelle est la différence entre une `inline` function et une `constexpr` function ? Quand éviter l’inline?
14. Quelles techniques utilisez-vous pour réduire les allocations mémoire dynamiques dans une boucle temps réel ?
15. Expliquez ce qu'est la "false sharing" en multithreading et comment l'éviter.
16. Comment implémenteriez-vous un thread pool moderne en C++20 ?
17. Comparez `std::mutex`, `std::shared_mutex` et `std::atomic`. Donnez un cas d’usage pour chacun.
18. Comment éviter les conditions de course sans utiliser de mutex?
19. Expliquez comment utiliser les coroutines (`co_await`, `co_yield`, `co_return`) pour modéliser un système asynchrone.
20. Quelles sont les implications de la mémoire "relaxed" dans `std::atomic`? Donnez un exemple précis.
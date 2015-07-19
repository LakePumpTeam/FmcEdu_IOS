//
//  FKRDefaultSearchBarTableViewController.m
//  TableViewSearchBar
//
//  Created by Fabian Kreiser on 10.02.13.
//  Copyright (c) 2013 Fabian Kreiser. All rights reserved.
//

#import "TaskSearchVC.h"

@implementation TaskSearchVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.tableHeaderView = self.searchBar;
    
}

- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableView scrollRectToVisible:self.searchBar.frame animated:animated];
}

@end
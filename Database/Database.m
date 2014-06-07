

#import "Database.h"

static Database *shareDatabase =nil;

@implementation Database
#pragma mark -
#pragma mark Database


+(Database*) shareDatabase{
	
	if(!shareDatabase){
		shareDatabase = [[Database alloc] init];
	}
	
	return shareDatabase;
	
}

#pragma mark -
#pragma mark Get DataBase Path
// Paas Your DataBase Name Over here
NSString * const DataBaseName  = @"chattfly.db";

- (NSString *) GetDatabasePath:(NSString *)dbName{
	NSArray  *paths        = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent:dbName];
}

-(BOOL) createEditableCopyOfDatabaseIfNeeded
{
    BOOL success; 
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DataBaseName];
    
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return success;
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DataBaseName];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    
    if (!success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!!!" message:@"Failed to create writable database" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
        
        }
    return success;
}


#pragma mark -
#pragma mark Get All Record

-(NSMutableArray *)SelectAllFromTable:(NSString *)query
{
	sqlite3_stmt *statement = nil ;
	NSString *path = [self GetDatabasePath:DataBaseName];
	
	NSMutableArray *alldata;
	alldata = [[NSMutableArray alloc] init];
	
	if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK )
	{
    
		if((sqlite3_prepare_v2(databaseObj,[query UTF8String],-1, &statement, NULL)) == SQLITE_OK)
		{
			while(sqlite3_step(statement) == SQLITE_ROW)
			{	
				
				NSMutableDictionary *currentRow = [[NSMutableDictionary alloc] init];
                
				int count = sqlite3_column_count(statement);
				
				for (int i=0; i < count; i++) {
                    
					char *name = (char*) sqlite3_column_name(statement, i);
					char *data = (char*) sqlite3_column_text(statement, i);
					
					NSString *columnData;   
					NSString *columnName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
                    
					if(data != nil){
						columnData = [NSString stringWithCString:data encoding:NSUTF8StringEncoding];
					}else {
						columnData = @"";
					}
                    
					[currentRow setObject:columnData forKey:columnName];
				}
                
				[alldata addObject:currentRow];
			}
		}
		sqlite3_finalize(statement); 
	}
	if(sqlite3_close(databaseObj) == SQLITE_OK){
    
    }else{
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
	return alldata;

}

#pragma mark -
#pragma mark Get Record Count

-(int)getCount:(NSString *)query
{
	int m_count=0;
	sqlite3_stmt *statement = nil ;
	NSString *path = [self GetDatabasePath:DataBaseName] ;
	
	if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK )
	{
		if((sqlite3_prepare_v2(databaseObj,[query UTF8String],-1, &statement, NULL)) == SQLITE_OK)
		{
			if(sqlite3_step(statement) == SQLITE_ROW)
			{	
				m_count= sqlite3_column_int(statement,0);
			}
		}
		sqlite3_finalize(statement); 
	}
	if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
	return m_count;
}

#pragma mark -
#pragma mark Check For Record Present

-(BOOL)CheckForRecord:(NSString *)query
{	
	sqlite3_stmt *statement = nil;
	NSString *path = [self GetDatabasePath:DataBaseName];
	int isRecordPresent = 0;
		
	if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK )
	{
		if((sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement, NULL)) == SQLITE_OK)
		{
			if(sqlite3_step(statement) == SQLITE_ROW)
			{
				isRecordPresent = 1;
			}
			else {
				isRecordPresent = 0;
			}
		}
	}
	sqlite3_finalize(statement);	
	if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }	
	return isRecordPresent;
}

#pragma mark -
#pragma mark Insert

- (void)Insert:(NSString *)query 
{	
	sqlite3_stmt *statement=nil;
	NSString *path = [self GetDatabasePath:DataBaseName];
	
	if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK)
	{
		if((sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement,NULL)) == SQLITE_OK)
		{
			sqlite3_step(statement);
		}
	}
	sqlite3_finalize(statement);
	if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
}

#pragma mark -
#pragma mark DeleteRecord

-(void)Delete:(NSString *)query
{
	sqlite3_stmt *statement = nil;
	NSString *path = [self GetDatabasePath:DataBaseName] ;
	if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK )
	{
		if((sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement, NULL)) == SQLITE_OK)
		{
			sqlite3_step(statement);
		}
	}
	sqlite3_finalize(statement);
	if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
}

#pragma mark -
#pragma mark UpdateRecord

-(void)Update:(NSString *)query
{
	sqlite3_stmt *statement=nil;
	NSString *path = [self GetDatabasePath:DataBaseName] ;
	
	if(sqlite3_open([path UTF8String],&databaseObj) == SQLITE_OK)
	{
		if(sqlite3_prepare_v2(databaseObj, [query UTF8String], -1, &statement, NULL) == SQLITE_OK)
		{
			sqlite3_step(statement);
		}
		sqlite3_finalize(statement);
	}
	if(sqlite3_close(databaseObj) == SQLITE_OK){
        
    }else{
        NSAssert1(0, @"Error: failed to close database on memwarning with message '%s'.", sqlite3_errmsg(databaseObj));
    }
}

@end

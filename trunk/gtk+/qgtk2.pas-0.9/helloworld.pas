uses qgtk2;                                                                      
begin                                                                           
qstart('Hello Word!', nil, nil);                                                
qLabel('  Hello word with ');                                                   
qButton(' QUIT button ', @qDestroy);                                            
qGo;                                                                            
end.
